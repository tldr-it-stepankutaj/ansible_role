# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in this project, please report it responsibly.

**Do not open a public GitHub issue for security vulnerabilities.**

Instead, please contact the maintainer directly:

- GitHub: [@tldr-it-stepankutaj](https://github.com/tldr-it-stepankutaj)

## What to include

When reporting a vulnerability, please include:

- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

## Response

You can expect an initial response within 72 hours. The maintainer will work with you to understand and address the issue before any public disclosure.

## Scope

This policy applies to the Ansible roles, playbooks, templates, and scripts in this repository. It does not cover infrastructure managed by these roles.

## Best Practices

This project follows these security practices:

- All secrets are managed via Ansible Vault (never committed in plaintext)
- SSH hardening with modern cipher suites
- Fail2ban for brute-force protection
- SELinux policy management
- Firewall configuration (iptables/nftables)
- CI/CD pipeline with ansible-lint and syntax checking
