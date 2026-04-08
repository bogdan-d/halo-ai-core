# Network Layout

## Three-Tier Network

| Network | Subnet | Purpose |
|---------|--------|---------|
| **Main** | 10.0.0.0/24 | Production machines, AI workloads |
| **IoT** | 192.168.50.0/24 | Smart home, cameras, isolated |
| **Guest** | Captive portal | Visitor access, fully isolated |

## Main Network Devices

| IP | Device | Role |
|----|--------|------|
| 10.0.0.1 | ASUS ZenWiFi ET12 | Gateway, DHCP, SSH |
| 10.0.0.10 | Strix Halo | AI inference |
| 10.0.0.20 | Sliger | Game servers, training |
| 10.0.0.25 | Ryzen | Primary desktop |
| 10.0.0.30 | Minisforum | Windows, office |
| 10.0.0.40 | Pi 5 | Media vault |
| 10.0.0.101 | JetKVM (Strix) | Remote console |
| 10.0.0.102 | JetKVM (Sliger) | Remote console |

## IP Scheme

- `.1` — Router
- `.2-.9` — Reserved
- `.10-.49` — Static reservations (machines)
- `.50-.99` — Reserved for future
- `.100-.109` — Management devices (JetKVM)
- `.110+` — DHCP pool

## DNS

- Pi-hole for ad blocking and local DNS
- DNS-over-TLS for upstream queries
- Local hostnames resolve via router DHCP

## DHCP Reservations

Set on the router by MAC address. Machines get the same IP every time without static config on the machine itself (except Pi, which uses NetworkManager static).

## Security

- Main and IoT networks are isolated
- Guest network has captive portal
- No cross-network routing between IoT and Main
- All inter-machine traffic is SSH encrypted

## Adding a New Machine

1. Connect to the network (gets a DHCP IP)
2. Find its MAC: `ip link show`
3. Add a static reservation on the router
4. Run the mesh bootstrap script
5. Machine joins the mesh

See [[SSH Mesh]] for the full mesh setup guide.
