# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 0.9.x   | ✅ current |

## Reporting a Vulnerability

If you discover a security vulnerability, please report it responsibly:

1. **DO NOT** create a public GitHub issue
2. Use [GitHub Security Advisories](https://github.com/stampby/halo-ai-core/security/advisories/new) to report privately
3. Include: description, steps to reproduce, impact assessment
4. You will receive a response within 48 hours

## Security Design

- All services bind to `localhost` only
- SSH key-only authentication (no passwords)
- Root login disabled
- Caddy reverse proxy as the only potential external listener
- ShellCheck + CodeQL on every push
- Weekly CodeQL scheduled scans
- Dependency review on every PR

## Past Incidents

- [axios supply chain attack (2026-03-31)](https://github.com/stampby/halo-ai/security/advisories/GHSA-3gp9-qwch-x5wv) — mitigated, tokens rotated, documented publicly

We believe in glass walls. Every incident is documented publicly.
