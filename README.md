# charliek/tap

Homebrew formulae for the CLIs and services I maintain — a git review TUI, a
JVM code analyzer, microVM dev environments, a dev process manager, and
encrypted env-file tooling.

## Install

```bash
brew tap charliek/tap
brew install strix
brew install codelens
brew install shed
brew install shed-host-agent
brew install shed-machine-rc
brew install prox
brew install envsecrets
```

## Formulae

| Formula | Description |
|---------|-------------|
| `strix` | Focused, polished TUI for staging changes and viewing diffs |
| `codelens` | Analyze JVM codebases (Java & Kotlin) — classes, methods, handlers, and more |
| `shed` | CLI and server for managing persistent VM-based dev environments |
| `shed-host-agent` | Host-side credential brokering agent for shed VMs |
| `shed-machine-rc` | RC session helper for native machines — create/watch `claude remote-control` sessions, the host-side sibling of `shed-ext-rc` |
| `prox` | Modern process manager for development with API-first design |
| `envsecrets` | CLI for managing encrypted environment files via GCS and age encryption |

## Usage

### strix

A two-pane terminal UI for staging and reviewing diffs, with first-class
mouse and keyboard support and syntax-highlighted side-by-side or unified
diffs.

```bash
strix              # open the repository in the current directory
strix path/to/repo # open a specific repository
strix --help       # full options (themes, --dump-frame, width/height)
```

- Repo: <https://github.com/charliek/strix>
- Docs: <https://charliek.github.io/strix/>

`strix` shells out to `git`, so make sure `git` is on your `PATH`.

### codelens

Analyze JVM codebases (Java & Kotlin) — classes, methods, annotations, type
hierarchies, call sites (`calls`), cross-references (`xref`), the dependency
graph (`deps`), and source.

codelens commands locate the per-project server by working directory, so
either `cd` into the project first or pass `-p path/to/project` (a global
flag) on every invocation:

```bash
cd path/to/project
codelens start                   # start the analysis server for this project
codelens classes list            # list classes
codelens methods --help          # search methods
codelens xref com.example.Foo    # what references this type?
codelens status                  # is the server running for this project?
codelens stop                    # stop the server for this project
codelens list                    # all running servers (no project needed)
codelens --help                  # all commands
```

Equivalently, from anywhere: `codelens -p path/to/project classes list`.

- Repo: <https://github.com/charliek/codelens>
- Docs: <https://charliek.github.io/codelens/>

Needs a JDK 21+ on the host — see [Services & setup](#services--setup).

### shed

CLI for creating and managing persistent VM-based dev environments. Pair it
with `shed-server` (the daemon) and optionally `shed-host-agent` (credential
brokering).

```bash
shed list                    # list sheds across all configured servers
shed create my-env           # create a new shed
shed attach my-env           # attach to the tmux session
shed ssh-config              # write SSH config entries for your sheds
shed --help                  # all commands
```

- Repo: <https://github.com/charliek/shed>
- Docs: <https://charliek.github.io/shed/>

`shed-server` runs as a brew service and needs config + Docker — see
[Services & setup](#services--setup).

### shed-host-agent

Host-side credential brokering daemon that lets shed VMs use your SSH agent,
AWS credentials, and Docker credential helpers without copying secrets into
the guest. Runs as a brew service.

```bash
shed-host-agent --help       # config flag (path to extensions.yaml)
```

- Repo: <https://github.com/charliek/shed-extensions>
- Docs: <https://charliek.github.io/shed-extensions/>

Configured and started as a service — see [Services & setup](#services--setup).

### shed-machine-rc

Host-side helper for **RC sessions on native machines** — the sibling of the in-shed
`shed-ext-rc`. Create, list, and tear down `claude remote-control` tmux sessions on a
laptop / workstation / tailnet host so
[shed-remote-agent](https://github.com/charliek/shed-remote-agent) (and, later,
shed-mobile) can watch them. Needs `claude` and `tmux` installed.

```bash
shed-machine-rc claude   # start a local auto-mode session, print its claude.ai URL, walk away
shed-machine-rc list     # list RC sessions on this machine
shed-machine-rc --help
```

- Repo: <https://github.com/charliek/shed-extensions>
- Docs: <https://charliek.github.io/shed-extensions/reference/shed-machine-rc/>

### prox

A modern process manager for local development: supervises a set of
processes (Procfile-like), aggregates logs, exposes an HTTP API and an
interactive TUI, and can run as a background daemon.

```bash
prox up                  # start processes defined in prox.yaml / Procfile
prox status              # show process status
prox logs                # tail aggregated logs
prox attach              # interactive TUI against the running daemon
prox stop                # stop the running instance
prox --help              # all commands
```

- Repo: <https://github.com/charliek/prox>
- Docs: <https://charliek.github.io/prox/>

### envsecrets

CLI for managing encrypted environment files using GCS + age encryption.
Push/pull workflow similar to git, with a `status` command that tells you
the safe action to take next.

```bash
envsecrets init           # initialize config (GCS bucket + age recipients)
envsecrets status         # show what to push, pull, or reconcile
envsecrets pull           # decrypt + sync down
envsecrets push           # encrypt + sync up
envsecrets doctor         # verify configuration and connectivity
envsecrets --help         # all commands
```

- Repo: <https://github.com/charliek/envsecrets>
- Docs: <https://charliek.github.io/envsecrets/>

## Services & setup

A few formulae need a bit more than `brew install` — background services,
extra runtime, or per-machine config.

### shed-server / shed-host-agent

Both run as background services:

```bash
brew services start shed            # start shed-server daemon
brew services start shed-host-agent # start credential brokering agent
brew services list                  # check status
brew services restart shed          # restart after config changes
```

Verify the credential agent is running and see which config it loaded:

```bash
shed-host-agent status              # queries the running agent (no flags needed)
```

Logs are at `$(brew --prefix)/var/log/shed-server.log` and
`$(brew --prefix)/var/log/shed-host-agent.log`.

Default configs are installed to `$(brew --prefix)/etc/shed/` and preserved
across upgrades:

- `server.yaml` — shed-server configuration
- `extensions.yaml` — shed-host-agent configuration

`shed-server` also requires Docker for VM image management. See the
[shed repo](https://github.com/charliek/shed) for the full setup.

### codelens

`codelens` runs a JDK 21+ server under the hood. Provide a JDK via SDKMAN
(`sdk install java 21.0.9-amzn`) or Homebrew (`brew install openjdk@21`), or
point `CODELENS_JAVA_HOME` / `JAVA_HOME` at a JDK 21+ home. codelens
auto-discovers JDKs from SDKMAN and Homebrew (`openjdk@21..@25`) and runs
the server on the newest it finds. Analyzing a target project may also
require that project's own JDK (likewise auto-discovered).

See the [codelens docs](https://charliek.github.io/codelens/) for the full
walkthrough.
