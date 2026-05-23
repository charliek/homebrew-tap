# charliek/tap

Homebrew formulae for [shed](https://github.com/charliek/shed) and related tools.

## Install

```bash
brew tap charliek/tap
brew install shed
brew install shed-host-agent
brew install prox
brew install envsecrets
brew install codelens
```

## Formulae

| Formula | Description |
|---------|-------------|
| `shed` | CLI and server for managing persistent VM-based dev environments |
| `shed-host-agent` | Host-side credential brokering agent for shed VMs |
| `prox` | Modern process manager for development with API-first design |
| `envsecrets` | CLI for managing encrypted environment files via GCS and age encryption |
| `codelens` | Analyze JVM codebases (Java & Kotlin) — classes, methods, handlers, and source |

`codelens` runs a JDK 21+ server under the hood. Provide a JDK via SDKMAN
(`sdk install java 21.0.9-amzn`) or Homebrew (`brew install openjdk@21`). See the
[codelens docs](https://charliek.github.io/codelens/).

## Services

Both `shed-server` and `shed-host-agent` can be managed as background services:

```bash
brew services start shed            # start shed-server daemon
brew services start shed-host-agent # start credential brokering agent
brew services list                  # check status
brew services restart shed          # restart after config changes
```

Logs are at `$(brew --prefix)/var/log/shed-server.log` and `$(brew --prefix)/var/log/shed-host-agent.log`.

## Configuration

Default configs are installed to `$(brew --prefix)/etc/shed/`:

- `server.yaml` — shed-server configuration
- `extensions.yaml` — shed-host-agent configuration

These files are preserved across upgrades.
