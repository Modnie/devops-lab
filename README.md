# DevOps Lab

Infrastructure automation project focused on building, securing, and monitoring Linux infrastructure using Infrastructure as Code practices.

The repository contains reusable Ansible automation, firewall configuration, and safe deployment tooling. Environment-specific configuration and secrets are kept outside the public repository.

## Current Infrastructure Automation

### Ansible

Ansible is used as the primary configuration management tool.

Current automation includes:

- Ubuntu server baseline configuration
- Package installation and system updates
- Timezone configuration
- SSH hardening
- nftables firewall deployment
- PostgreSQL installation and configuration
- Zabbix Server deployment
- Zabbix Agent 2 deployment
- Service management through systemd
- Ansible Vault integration for secrets
- Environment-specific configuration through inventory variables

### Monitoring

The monitoring stack is based on Zabbix 7.0 LTS.

Current components:

- Zabbix Server
- Zabbix Web Frontend
- PostgreSQL backend
- Zabbix Agent 2
- Automated agent deployment using Ansible

Linux hosts can be added to the monitoring infrastructure using the reusable `zabbix_agent` role.

### Firewall as Code

Host firewall configuration is managed using nftables.

The repository contains:

- version-controlled nftables configuration
- configuration validation before deployment
- management network access control
- service-specific firewall rules
- safe deployment and rollback scripts

Private environment-specific firewall configuration is excluded from Git.

## Repository Structure

```text
devops-lab/
├── ansible/
│   ├── ansible.cfg
│   ├── inventory/
│   ├── playbooks/
│   │   ├── baseline.yml
│   │   ├── monitoring.yml
│   │   └── zabbix_agents.yml
│   ├── roles/
│   │   ├── postgresql/
│   │   ├── zabbix/
│   │   └── zabbix_agent/
│   └── templates/
│       ├── 10-hardening.conf.j2
│       └── nftables.conf.j2
│
├── firewall/
│   └── nftables.conf
│
├── scripts/
│   ├── deploy-firewall.sh
│   └── rollback-firewall.sh
│
├── .gitignore
└── README.md
```

## Ansible Playbooks

### `baseline.yml`

Applies the base configuration for Linux servers.

Current baseline automation includes:

- package updates
- common administration tools
- timezone configuration
- QEMU Guest Agent
- SSH hardening
- nftables firewall configuration
- required systemd service management

### `monitoring.yml`

Deploys the monitoring server stack using reusable Ansible roles.

Current roles:

- `postgresql`
- `zabbix`

The playbook installs and configures the PostgreSQL database and Zabbix monitoring stack.

### `zabbix_agents.yml`

Deploys and configures Zabbix Agent 2 on managed Linux hosts using the reusable `zabbix_agent` role.

Agent configuration includes:

- Zabbix server address
- active server address
- host identity based on Ansible inventory
- automatic service enablement and startup

## Ansible Roles

### `postgresql`

Installs PostgreSQL and required Python dependencies, starts the database service, and creates the database and database user required by Zabbix.

Database credentials are supplied through Ansible Vault and are not stored in plaintext in the public repository.

### `zabbix`

Deploys the Zabbix monitoring server stack.

The role currently handles:

- official Zabbix repository configuration
- Zabbix Server installation
- Zabbix Web Frontend installation
- PostgreSQL support
- initial database schema import
- Zabbix database configuration
- nginx frontend configuration
- Zabbix and web service management

Database schema initialization is performed conditionally to keep repeated Ansible runs idempotent.

### `zabbix_agent`

Installs and configures Zabbix Agent 2 on managed Linux systems.

The role is reusable across multiple hosts and derives host-specific configuration from the Ansible inventory.

## Configuration and Secrets

The repository separates reusable infrastructure code from environment-specific configuration.

Public configuration contains reusable defaults and examples, while real infrastructure values are stored in local files excluded from Git.

Sensitive information is managed separately using Ansible Vault.

Examples of information excluded from the public repository include:

- production IP addresses and networks
- local Ansible inventory
- database credentials
- environment-specific variables
- host-specific private configuration

This allows the repository to remain reusable without exposing details of the real infrastructure.

## Firewall Deployment

nftables configuration is maintained as code and can be validated before being applied to a host.

Deployment tooling is designed around a safe workflow:

1. validate the new configuration
2. prepare automatic rollback
3. apply the new ruleset
4. verify management connectivity
5. cancel rollback after successful validation
6. persist the working configuration

This reduces the risk of losing remote access while changing firewall rules.

## Design Principles

The project follows several infrastructure engineering principles:

- Infrastructure as Code
- reproducible configuration
- idempotent automation
- reusable Ansible roles
- separation of code and environment-specific configuration
- secrets kept outside the public Git repository
- least-privilege network access
- configuration validation before deployment
- safe rollback for network configuration changes
- version-controlled infrastructure changes

## Status

The project is actively evolving as additional infrastructure components are automated and integrated into the configuration management and monitoring stack.
