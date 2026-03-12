# Ansible Infrastructure

Ansible configuration management for automating Linux server provisioning, hardening, and upgrades. Supports Debian, RedHat, OpenBSD, and FreeBSD.

## Quick Start

```bash
# Install required collections
ansible-galaxy collection install -r requirements.yml

# Syntax check
ansible-playbook playbooks/common.yml --syntax-check

# Dry-run (preview changes without applying)
ansible-playbook playbooks/common.yml --check --diff

# Apply base infrastructure
ansible-playbook playbooks/common.yml

# Run specific roles by tag
ansible-playbook playbooks/common.yml --tags ssh,network

# Upgrade all hosts
ansible-playbook playbooks/upgrade.yml

# Upgrade with reboot enabled
ansible-playbook playbooks/upgrade.yml -e upgrade_reboot=true

# Upgrade a specific group, one host at a time
ansible-playbook playbooks/upgrade.yml --limit dbservers -e upgrade_serial=1

# Automated validation of all playbooks
./scripts/ansible-playbook-check-diff
```

## Playbooks

| Playbook | Target | Purpose |
|----------|--------|---------|
| `playbooks/common.yml` | All hosts (except `pg`) | Base infrastructure: motd, network, ssh, base, sysusers, sudo |
| `playbooks/postgresql.yml` | `pg` group | PostgreSQL 17 deployment |
| `playbooks/upgrade.yml` | All hosts | System package upgrades with optional reboot handling |

## Roles

### System and Base

| Role | Description |
|------|-------------|
| `base` | Core packages, bashrc, vim config, system scripts |
| `motd` | Message of the day |
| `sysusers` | System user account management |
| `sudo` | Sudo access control |
| `sysctl` | Kernel parameter tuning |
| `logrotate` | Log rotation configuration |
| `ntpd` | NTP time synchronization |

### Networking and Security

| Role | Description |
|------|-------------|
| `network` | Network interface and routing configuration |
| `ssh` | OpenSSH hardening (modern ciphers, SFTP chroot jailing) |
| `iptables` | iptables firewall rules |
| `nftables` | nftables firewall (modern replacement for iptables) |
| `fail2ban` | Brute-force attack protection |
| `selinux` | SELinux policy management |
| `keepalived` | High availability / VRRP |

### VPN and PKI

| Role | Description |
|------|-------------|
| `openvpn` | OpenVPN server with Easy-RSA integration |
| `strongswan` | IPSec/IKEv2 VPN server |
| `easyrsa` | PKI / Certificate Authority management |

### Databases

| Role | Description |
|------|-------------|
| `postgresql` | PostgreSQL 17 installation and configuration |
| `percona-server` | Percona Server (MySQL) -- multi-version (5.6, 5.7, 8.0) |
| `xtradb-cluster` | Percona XtraDB Cluster (MySQL clustering) |

### Web, Caching and Monitoring

| Role | Description |
|------|-------------|
| `haproxy` | HAProxy load balancer / reverse proxy |
| `redis` | Redis cache / message broker |
| `prometheus_node_exporter` | Prometheus node metrics exporter |
| `htpasswd` | HTTP basic auth file management |
| `rsyncd` | rsync daemon configuration |

### Upgrade

| Role | Description |
|------|-------------|
| `upgrade` | System package upgrades with conditional reboot |

The `upgrade` role performs a full system package upgrade and optionally reboots the host if a reboot is required. It is driven by the `playbooks/upgrade.yml` playbook, which includes post-tasks to wait for the server to come back online and verify it is operational.

**Variables:**

| Variable | Default | Description |
|----------|---------|-------------|
| `upgrade_serial` | `100%` | How many hosts to upgrade in parallel (e.g., `1`, `25%`, `100%`) |
| `upgrade_reboot` | `false` | Whether to reboot hosts after upgrade if required |
| `upgrade_reboot_delay` | `30` | Seconds to wait before checking if the host is back |
| `upgrade_reboot_timeout` | `300` | Maximum seconds to wait for the host to come back |
| `upgrade_reboot_force` | `false` | Force reboot even if the system does not report one as required |

**Examples:**

```bash
# Upgrade all hosts, no reboot
ansible-playbook playbooks/upgrade.yml

# Upgrade with reboot
ansible-playbook playbooks/upgrade.yml -e upgrade_reboot=true

# Rolling upgrade of web servers, one at a time
ansible-playbook playbooks/upgrade.yml --limit webservers -e upgrade_serial=1

# Force reboot after upgrade
ansible-playbook playbooks/upgrade.yml -e upgrade_reboot=true -e upgrade_reboot_force=true
```

## Inventory

The inventory file `hosts` is not tracked in git. Copy the provided example and adjust it to your environment:

```bash
cp hosts.example hosts
```

The example inventory (`hosts.example`) includes group definitions for webservers, database servers, PostgreSQL, monitoring, and VPN hosts. Group variables set the deploy user, enable privilege escalation, and configure per-group upgrade behavior (e.g., serial upgrades for database servers).

## Vault and Secrets Management

Secrets are managed via Ansible Vault. The vault password file (`.vault_password`) is gitignored.

- Vault variables use the `vault_` prefix in `group_vars/all/vault.yml`
- Role defaults reference these via mappings in `group_vars/all/main.yml`
- To edit secrets: `ansible-vault edit group_vars/all/vault.yml`
- Never commit plaintext passwords in role defaults

## Project Structure

```
ansible.cfg          # Ansible configuration (inventory, paths, SSH pipelining)
hosts                # Inventory file (not tracked, copy from hosts.example)
hosts.example        # Sample inventory with group definitions
group_vars/          # Group variables and vault secrets
playbooks/           # Playbooks (common, postgresql, upgrade)
roles/               # All roles (defaults, vars, tasks, handlers, templates, files)
files/               # Support files (utility scripts deployed by base role)
scripts/             # Validation and cron scripts
```

## Multi-Distribution Support

Roles detect the target OS and load distribution-specific tasks and variables automatically:

```yaml
- include_tasks: "{{ item }}"
  with_first_found:
    - "{{ ansible_distribution }}.yml"
    - "{{ ansible_os_family }}.yml"
```

Supported OS families: Debian (including Ubuntu), RedHat (including CentOS, AlmaLinux, Fedora), OpenBSD, and FreeBSD.

## Testing

Molecule tests exist for select roles: `ssh`, `base`, `network`, `percona-server`, `haproxy`.

```bash
# Run Molecule tests for a specific role
cd roles/ssh && molecule test
```

CI runs via GitHub Actions (`.github/workflows/lint.yml`), which executes ansible-lint and syntax-check on all playbooks.

## Requirements

- Ansible 2.9+
- SSH access to target hosts
- Python 3 on target hosts
- Collections listed in `requirements.yml`
