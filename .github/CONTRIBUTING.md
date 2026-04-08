# Contributing to Halo AI Core

## The Rule

Core stays lean. If it's not one of the five core services (ROCm, Caddy, llama.cpp, Lemonade, Gaia), it's a lego block. Lego blocks go in the wiki, not in core.

## How to Contribute

1. Fork the repo
2. Create a branch (`git checkout -b my-fix`)
3. Make your changes
4. Run `./install.sh --dry-run` to verify
5. Commit with a clear message
6. Open a PR

## What We Accept

- Bug fixes to the install script
- Documentation improvements
- New wiki pages for lego blocks
- Translation improvements
- CI/CD improvements

## What We Don't Accept

- New services added to core
- Breaking changes to the install flow
- Dependencies on external services or APIs
- Anything that phones home

## Style

- Lowercase in README (matches the project voice)
- Movie quotes encouraged
- Keep it simple. If it needs a paragraph to explain, it's too complex.

## Security

Report vulnerabilities via [GitHub Security Advisories](https://github.com/stampby/halo-ai-core/security/advisories/new), not public issues.
