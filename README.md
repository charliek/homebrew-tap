# charliek/tap

Homebrew formulae for [shed](https://github.com/charliek/shed) and related tools.

## Install

```bash
brew tap charliek/tap
brew install shed
brew install shed-host-agent
brew install prox
```

## Formulae

| Formula | Description |
|---------|-------------|
| `shed` | CLI and server for managing persistent VM-based dev environments |
| `shed-host-agent` | Host-side credential brokering agent for shed VMs |
| `prox` | Modern process manager for development with API-first design |

## Services

Both `shed-server` and `shed-host-agent` can be managed as background services:

```bash
brew services start shed            # start shed-server daemon
brew services start shed-host-agent # start credential brokering agent
brew services list                  # check status
brew services log shed              # view shed-server logs
brew services log shed-host-agent   # view host-agent logs
```

## Configuration

Default configs are installed to `$(brew --prefix)/etc/shed/`:

- `server.yaml` — shed-server configuration
- `extensions.yaml` — shed-host-agent configuration

These files are preserved across upgrades.
