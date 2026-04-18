# halo-mcp ↔ lemonade-nexus — design

Status: draft (2026-04-18). Stamped for architect review.

## Goal

Every machine running halo-ai is a **verified brain node** in a Lemonade-Nexus mesh. A C++ MCP server (`halo-mcp`) on each node advertises its agent-cpp specialists as MCP tools, discovers peer nodes through nexus gossip, and lets local Claude Code clients invoke tools on remote nodes over the authenticated WireGuard tunnel.

## Constraints (locked)

- **Language:** C++20. Standalone binary. Links `libagent_cpp.a` and `liblemonade_nexus_sdk.a`.
- **Transport to local MCP clients:** stdio / JSON-RPC 2.0 (Claude Code spawns it per-session).
- **Transport between nodes:** HTTPS over the WireGuard tunnel (nexus private API pattern — bind to tunnel IP, request ACME cert via nexus `request_certificate()`).
- **No Python anywhere.** No hipBLAS at runtime.
- **Identity:** Ed25519 keypair at `~/.config/halo-mcp/identity.key`, created on first run and registered with nexus via `authenticate_ed25519()`.

## Component layout

```
halo-mcp (binary)
├── StdioServer        JSON-RPC 2.0 loop, reads /dev/stdin, writes /dev/stdout
├── ToolRegistry       enumerates agent-cpp specialists → JSON schemas
├── BusBridge          MCP tools/call → agent-cpp message bus, awaits reply
├── CVGGate            pre-dispatch consent check (reuse libagent_cpp CVG)
├── AuditChain         append-only hash-chained log (reuse libagent_cpp audit)
├── NexusClient        wraps LemonadeNexusClient — auth, mesh, tunnel, tree
├── PeerRegistry       local view of known peers + their advertised tools
├── RemoteDispatcher   routes a tools/call to a peer over the tunnel
└── TreeAdvertiser     publishes our tool manifest to nexus tree on join
```

## Startup sequence

```
1. load_or_generate_identity()                  — ~/.config/halo-mcp/identity.key
2. NexusClient client(config)
   client.set_identity(id)
3. client.authenticate_ed25519()                — gets session token
4. client.join_network(...)                     — allocates tunnel IP, assigns node_id
5. client.tunnel_up(config)                     — WireGuard up
6. client.enable_mesh()                         — peer discovery starts
7. client.set_mesh_callback([](state){...})     — watch for peer join/leave
8. TreeAdvertiser publishes tool manifest under /halo-ai/nodes/<node_id>/tools
9. Start StdioServer on stdin/stdout            — ready to serve local MCP clients
10. Start private HTTPS server on tunnel_ip:9200 — ready to serve remote peers
```

## Wire-level data flow

### Case A — local call, local tool
```
Claude Code → stdio → StdioServer
            → CVGGate(policy/intent/consent/bounds)
            → BusBridge → agent-cpp bus → specialist → reply
            → AuditChain.append()
            → stdio response to Claude Code
```

### Case B — local call, remote tool
```
Claude Code → stdio → StdioServer
            → PeerRegistry.resolve(tool_name) → peer_id
            → RemoteDispatcher:
                HTTPS POST https://<peer_tunnel_ip>:9200/mcp/tools/call
                Ed25519-signed request body
            → (peer executes locally via Case A, returns response)
            → AuditChain.append() (both sides log, chains remain independent)
            → stdio response to Claude Code
```

### Case C — remote call arrives
```
Peer → HTTPS :9200 → verify Ed25519 sig against nexus-known pubkey
     → CVGGate with inbound-remote-call policy (stricter than local)
     → BusBridge → specialist → reply
     → AuditChain.append() with peer_id recorded
     → HTTPS response
```

## Tool manifest advertisement (tree)

On startup, `TreeAdvertiser` publishes:

```
/halo-ai/nodes/<node_id>/
    meta               { version, arch, capabilities, uptime }
    tools/
        <tool_name>    { schema, description, side_effects, consent_scope }
```

Peers read `/halo-ai/nodes/*/tools` via `client.get_children()`; updates arrive via nexus gossip deltas (`client.set_mesh_callback()` fires on peer state change, we then poll the tree).

**ACL:** tool nodes are readable by the `/halo-ai/members` group; callable over HTTPS requires the caller's pubkey to be in `<tool_name>/allowed_callers`. Deltas signed with Ed25519, replayed via gossip.

## CVG on the inbound remote path

Remote calls pass through a **stricter CVG policy** than local:
- `intent` must be declared in the signed request envelope (free-form string, logged).
- `consent_scope` on the tool node acts as an upper bound — a remote caller can never exceed what the tool declares.
- `bounds` (rate limits, resource caps) apply per-peer, not per-call.
- Specialists with side effects (herald/quartermaster/magistrate/anvil) are off by default for remote callers; require explicit addition to `allowed_callers`.

## Audit chain across nodes

Each node's audit chain stays **independent** (genesis-seeded per-session). Remote calls are logged on **both sides** with the other party's pubkey and the request UUID — so a third party auditing both chains can correlate across the mesh without a shared chain.

## Failure modes + answers

| Mode | Response |
|---|---|
| Nexus unreachable at startup | Fall back to local-only mode; retry nexus join every 30s; MCP still works for Claude Code on this box. |
| Peer goes away mid-call | RemoteDispatcher returns JSON-RPC error -32001 "peer unreachable"; local AuditChain still logs the failed attempt. |
| Peer pubkey not in nexus trust tree | Reject inbound call with HTTP 401 before CVG runs; log via AuditChain. |
| Tunnel flaps | `enable_auto_switching()` handles nexus server migration; mesh peers re-heartbeat; in-flight calls fail fast. |
| CVG denies outbound | StdioServer returns JSON-RPC error -32002 "consent denied" with CVG reason; no network traffic emitted. |

## Build integration

New CMake target in `agent-cpp`:
```cmake
find_package(LemonadeNexusSDK REQUIRED)

add_executable(halo_mcp
    mcp/src/main.cc
    mcp/src/stdio_server.cc
    mcp/src/tool_registry.cc
    mcp/src/bus_bridge.cc
    mcp/src/nexus_client_wrap.cc
    mcp/src/peer_registry.cc
    mcp/src/remote_dispatcher.cc
    mcp/src/tree_advertiser.cc
)
target_link_libraries(halo_mcp PRIVATE
    agent_cpp_static              # libagent_cpp.a — bus, CVG, audit
    lnsdk::LemonadeNexusSDK       # nexus client SDK
    nlohmann_json::nlohmann_json
    # no hipBLAS, no python
)
target_compile_features(halo_mcp PRIVATE cxx_std_20)
```

## Phased rollout

**Phase 0 (v0.1, local-only):** StdioServer + ToolRegistry + BusBridge + CVGGate + AuditChain. No nexus. Claude Code → stdio → agent-cpp specialists. Read-only specialists only (scribe, librarian, cartograph, sentinel-read).

**Phase 1 (v0.2, nexus-enrolled, local-only):** Add NexusClient, join mesh, advertise tool manifest to tree. Don't accept remote calls yet. Peers see us and our tools; we see theirs.

**Phase 2 (v0.3, federated):** Add private HTTPS :9200 server, RemoteDispatcher, remote-call CVG policy. Peer tools become callable through our StdioServer. Still read-only.

**Phase 3 (v0.4, write specialists):** Allow herald/quartermaster/magistrate/anvil over remote call, one at a time, each gated by `allowed_callers` on the tool node. Per-specialist CVG consent scope.

**Phase 4 (v0.5, auto-switching + latency-aware routing):** Use `client.server_latencies()` and `RemoteDispatcher` picks the closest peer when multiple nodes advertise the same tool.

## Open questions for the architect

1. **Node config location** — `~/.config/halo-mcp/config.toml` or `/etc/halo-mcp/config.toml`? (Recommend `~/.config` for user-scope install, `/etc` only for system-wide.)
2. **Private HTTPS port** — 9200 is free on stampby's reference ports; does it conflict with anything in the lemonade ecosystem?
3. **Tree subtree root** — is `/halo-ai/` the right namespace, or does the architect want it under `/apps/halo-mcp/`?
4. **CVG remote-policy default** — deny-by-default for remote callers, even for read-only specialists? (Recommend yes — explicit opt-in per tool via `allowed_callers`.)
5. **Multi-binary-per-host** — if a host runs both halo-mcp and another MCP server (say halo-browser), do they share a nexus node_id or enroll as siblings? (Recommend siblings — separate tool namespaces, one nexus per machine stays the norm.)

## References

- SDK header: `/home/bcloud/repos/lemonade-nexus/projects/LemonadeNexusSDK/include/LemonadeNexusSDK/LemonadeNexusClient.hpp`
- Nexus architecture diagram: `/home/bcloud/repos/lemonade-nexus/README.md` (dual HTTP server, ports table)
- agent-cpp existing structures (bus, CVG, audit): `/home/bcloud/repos/halo-ai-core` → clones of `agent-cpp` during `install-source.sh`
