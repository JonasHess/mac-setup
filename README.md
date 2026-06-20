# mac-setup

One command to set up a fresh Mac: install your apps and tools with Homebrew,
clone your dotfiles and symlink them into place, and apply your macOS defaults.

The script is **generic and reusable**. Everything machine- or person-specific
lives in a config file that you pass as an argument, so the same script works for
different devices and different people — each just brings its own config.

```bash
git clone git@github.com:JonasHess/mac-setup.git ~/repos/mac-setup
cd ~/repos/mac-setup
./setup.sh configs/jonas.sh
```

## How it works

You declare the desired end state in a config file; the script makes the machine
match it. It is **idempotent** — run it as often as you like. Already-installed
packages are skipped, correct symlinks are left alone, and any real file about to
be replaced is backed up first.

A run does, in order:

1. **Homebrew** — installs Homebrew itself if missing.
2. **Wave 1 (essentials)** — installs `*_ESSENTIAL` formulae/casks: just enough
   to set up and use your dotfiles (e.g. `stow`, the shell, the prompt font).
3. **Dotfiles** — clones (or updates) your dotfiles repo (including submodules)
   and links it into `$HOME` via GNU Stow or per-file symlinks, backing up
   anything already there.
4. **macOS defaults** — runs your system-preferences script (e.g. `~/.osx`).
5. **Wave 2 (the rest)** — installs `BREW_PACKAGES` / `BREW_CASKS` / `MAS_APPS`:
   all the heavier and optional tools and apps.
6. **"Open in IntelliJ"** — optionally builds the Finder "Open With" helper app
   (`INTELLIJ_OPENER`).
7. **Language packages** — optional global npm / pip / gem / SDKMAN installs.
8. **MCP servers** — optionally installs and registers Claude Code MCP servers
   (`MCP_SERVERS`), prompting for any missing secrets.

## Usage

```bash
./setup.sh <config-file> [--dry-run]
```

- `<config-file>` — a shell config file, e.g. `configs/jonas.sh`.
- `--dry-run` — print every action (including the generated Brewfile) and change
  nothing. **Always a safe way to preview a run.**

```bash
./setup.sh configs/jonas.sh --dry-run   # preview
./setup.sh configs/jonas.sh             # for real
```

## Adding your own config (use it on another Mac, or share it)

There are two styles. Both produce a `configs/<name>.sh` you pass to `setup.sh`.

**A. Standalone** — copy the fully-commented template and edit it:

```bash
cp configs/example.sh configs/<name>.sh
# edit configs/<name>.sh, then:
./setup.sh configs/<name>.sh
```

**B. Build on the shared defaults** (recommended when several configs mostly
agree — e.g. `configs/jonas.sh` and `configs/michael.sh`). Put everything common
in [`configs/default.sh`](configs/default.sh) and keep each person's config thin:

```bash
# configs/<name>.sh
# 1. Personal identity — set BEFORE sourcing default.sh (SECRETS_FILE is
#    derived from DOTFILES_DEST).
DOTFILES_REPO="git@github.com:you/dotfiles.git"
DOTFILES_DEST="$HOME/repos/dotfiles"

# 2. Pull in the shared defaults.
source "$(dirname "${BASH_SOURCE[0]}")/default.sh"

# 3. Personal tweaks — AFTER sourcing: add, remove, or override.
BREW_CASKS+=( jabra-direct )        # add an app
BREW_CASKS_REMOVE=( spotify )       # drop a default app (see below)
CLEAR_DOCK=true                     # override a shared scalar
```

Because each machine/person has its own config, you keep one shared script and as
many configs as you have devices or users. Differences between machines are just
differences between config files.

### Adding and removing entries

Any list variable can be extended with `+=( ... )` and trimmed with a companion
`<NAME>_REMOVE=( ... )` array (bash has no `-=` operator). For example, to start
from `default.sh` but skip a couple of defaults:

```bash
BREW_PACKAGES_REMOVE=( wireshark nmap )
BREW_CASKS_REMOVE=( spotify )
```

`_REMOVE` works for `BREW_TAPS`, `BREW_PACKAGES(_ESSENTIAL)`,
`BREW_CASKS(_ESSENTIAL)`, `MAS_APPS`, `NPM_PACKAGES`, `PIP_PACKAGES`,
`GEM_PACKAGES`, `SDKMAN_CANDIDATES`, `MCP_SERVERS`, `INTELLIJ_DEFAULT_FOR`, and
`DOTFILES_FILES`. Always preview with `--dry-run`.

## Config reference

All options are documented in [`configs/example.sh`](configs/example.sh). In short:

| Variable | Purpose |
| --- | --- |
| `BREW_TAPS` | Extra Homebrew package sources |
| `BREW_PACKAGES_ESSENTIAL` | Wave 1 formulae — installed before dotfiles |
| `BREW_CASKS_ESSENTIAL` | Wave 1 casks — installed before dotfiles |
| `BREW_PACKAGES` | Wave 2 formulae (command-line tools) |
| `BREW_CASKS` | Wave 2 casks (GUI apps) |
| `CASK_APPDIR` | Where casks install `.app`s (default `/Applications`) |
| `MAS_APPS` | Mac App Store apps, as `"Name\|id"` |
| `DOTFILES_REPO` | Git URL of your dotfiles repo |
| `DOTFILES_DEST` | Where to clone it (default `~/repos/dotfiles`) |
| `DOTFILES_VERSION` | Branch / tag / commit to check out |
| `DOTFILES_ACCEPT_HOSTKEY` | Auto-accept the SSH host key on first clone |
| `DOTFILES_METHOD` | `stow` (GNU Stow) or `symlink` (per-file) |
| `DOTFILES_STOW_TARGET` | Target dir for stow (default `$HOME`) |
| `DOTFILES_FILES` | Files to symlink (only when method is `symlink`) |
| `MACOS_SCRIPT` | System-preferences script to run (e.g. `~/.osx --no-restart`) |
| `CLEAR_DOCK` | `true` to empty the Dock of all pinned apps |
| `NPM_PACKAGES` / `PIP_PACKAGES` / `GEM_PACKAGES` | Optional global packages |
| `SDKMAN_CANDIDATES` | SDKMAN installs as `"<candidate> <version>"` (e.g. `"java 17.0.19-amzn"`); installs SDKMAN if missing |
| `INTELLIJ_OPENER` | `true` to build the "Open in IntelliJ" Finder helper (`INTELLIJ_DEFAULT_FOR` sets default-handler extensions) |
| `MCP_SERVERS` + `MCP_<NAME>_*` | Claude Code MCP servers to install/register (secrets via `SECRETS_FILE`) |
| `<NAME>_REMOVE` | Companion array to drop entries from any list variable (e.g. `BREW_CASKS_REMOVE`) |

## Notes

- **Mac App Store**: you must be signed in to the App Store first; the `mas` tool
  is installed automatically when `MAS_APPS` is non-empty.
- **Backups**: replaced files go to `~/.mac-setup-backups/<timestamp>/`.
- **Requirements**: a Mac with the Command Line Tools (Homebrew prompts to install
  them if needed). The script targets the system `bash`, so no setup is required
  before the first run.
