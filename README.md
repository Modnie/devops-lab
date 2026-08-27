# Linux Firewall as Code

Infrastructure-as-Code project for managing a Linux firewall based on nftables.

The project provides a reproducible, version-controlled and safe approach to firewall configuration, deployment and rollback.

## Goals

- Manage nftables configuration as code
- Store firewall configuration in Git
- Validate configuration before deployment
- Provide repeatable and predictable deployment
- Protect remote systems from configuration errors
- Automatically rollback unsuccessful firewall changes
- Keep environment-specific settings separated from firewall logic
- Prepare the configuration for automated deployment with Ansible

## Architecture

```text
Git repository
      │
      ▼
nftables configuration
      │
      ▼
configuration validation
      │
      ▼
backup current configuration
      │
      ▼
schedule automatic rollback
      │
      ▼
deploy configuration
      │
      ▼
Linux nftables
      │
      ▼
verify connectivity
      │
      ├── success → cancel rollback
      │
      └── failure → automatic rollback
```

## Repository Structure

```text
devops-lab/
├── firewall/
│   └── nftables.conf
├── scripts/
│   ├── deploy-firewall.sh
│   └── rollback-firewall.sh
└── README.md
```

## Firewall Configuration

`firewall/nftables.conf` is the source of truth for the firewall configuration.

The current implementation includes:

- Default DROP policy for inbound traffic
- Loopback traffic handling
- Stateful connection tracking
- Trusted network definition
- nftables sets for allowed services
- Controlled access to management and application ports

Example configuration:

```nft
define LAN_NET = 192.168.69.0/24

table inet devops_filter {

    set lan_tcp_ports {
        type inet_service
        elements = { 22, 8080 }
    }

    chain input {
        type filter hook input priority filter;
        policy drop;

        iifname "lo" counter accept
        ct state established,related counter accept

        ip saddr $LAN_NET tcp dport @lan_tcp_ports counter accept
    }
}
```

## Configuration Validation

Before deployment, the nftables configuration is checked for syntax errors:

```bash
sudo nft -c -f firewall/nftables.conf
```

Invalid configurations are rejected before the active firewall is modified.

## Deployment

Deploy the current firewall configuration:

```bash
./scripts/deploy-firewall.sh
```

The deployment process:

1. Validates the new nftables configuration
2. Creates a backup of the currently deployed configuration
3. Schedules an automatic rollback
4. Copies the new configuration to `/etc/nftables.conf`
5. Applies the new nftables ruleset
6. Displays the active firewall configuration
7. Allows the administrator to verify connectivity and services

## Rollback Protection

Before the new firewall configuration is applied, the deployment script creates a transient systemd timer.

The timer automatically restores the previous firewall configuration if the administrator loses access to the server or does not confirm the deployment.

The current rollback timeout is:

```text
2 minutes
```

After verifying SSH connectivity and required services, cancel the scheduled rollback:

```bash
sudo systemctl stop firewall-rollback.timer
```

If the rollback timer is not cancelled, the previous firewall configuration is restored automatically.

## Manual Rollback

The previous configuration can also be restored manually:

```bash
sudo ./scripts/rollback-firewall.sh
```

The rollback script:

1. Restores the previous `/etc/nftables.conf`
2. Applies the restored nftables ruleset

## Git Workflow

Firewall changes are managed through Git.

Typical workflow:

```text
edit firewall configuration
        │
        ▼
review changes
        │
        ▼
validate nftables configuration
        │
        ▼
git add
        │
        ▼
git commit
        │
        ▼
git push
        │
        ▼
deploy
        │
        ▼
verify connectivity
        │
        ├── success → cancel rollback
        │
        └── failure → automatic rollback
```

This provides version history and makes it possible to track, review and reproduce firewall configuration changes.

## Security Model

The project follows a default-deny approach.

Inbound traffic is dropped unless explicitly allowed.

Current trusted services are defined through nftables sets, allowing firewall policy to remain readable and easy to modify.

Firewall configuration is validated before deployment, and automatic rollback protection reduces the risk of losing remote access because of an incorrect but syntactically valid configuration.

## Planned Improvements

The project is intended to evolve into a reusable Linux firewall deployment framework.

Planned improvements include:

- Environment-specific configuration
- Separation of environment variables from firewall logic
- Separate INPUT, FORWARD and NAT policies
- Multiple network zones
- VLAN support
- DMZ support
- Routing and forwarding
- NAT
- Firewall logging
- Monitoring
- Automated configuration testing
- Ansible deployment
- CI-based nftables validation
- Multiple-host deployment
