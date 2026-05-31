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

1. **Homebrew** — installs Homebrew itself if missing, then installs all taps,
   formulae, casks and Mac App Store apps from your config via `brew bundle`.
2. **Dotfiles** — clones (or updates) your dotfiles repo (including submodules)
   and links it into `$HOME` via GNU Stow or per-file symlinks, backing up
   anything already there.
3. **macOS defaults** — runs your system-preferences script (e.g. `~/.osx`).
4. **Language packages** — optional global npm / pip / gem installs.

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

1. Copy the template:
   ```bash
   cp configs/example.sh configs/<name>.sh
   ```
2. Edit `configs/<name>.sh` — it is fully commented. Set your Homebrew lists, your
   dotfiles repo and files, and your macOS script. Leave anything empty to skip it.
3. Run it:
   ```bash
   ./setup.sh configs/<name>.sh
   ```

Because each machine/person has its own config, you keep one shared script and as
many configs as you have devices or users. Differences between machines are just
differences between config files.

## Config reference

All options are documented in [`configs/example.sh`](configs/example.sh). In short:

| Variable | Purpose |
| --- | --- |
| `BREW_TAPS` | Extra Homebrew package sources |
| `BREW_PACKAGES` | Formulae (command-line tools) |
| `BREW_CASKS` | Casks (GUI apps) |
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

## Notes

- **Mac App Store**: you must be signed in to the App Store first; the `mas` tool
  is installed automatically when `MAS_APPS` is non-empty.
- **Backups**: replaced files go to `~/.mac-setup-backups/<timestamp>/`.
- **Requirements**: a Mac with the Command Line Tools (Homebrew prompts to install
  them if needed). The script targets the system `bash`, so no setup is required
  before the first run.
