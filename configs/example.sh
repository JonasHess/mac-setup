#!/usr/bin/env bash
#
# Example config for mac-setup. Copy this to configs/<your-name-or-host>.sh,
# edit it, then run:  ./setup.sh configs/<your-name-or-host>.sh
#
# This file is `source`d by setup.sh, so it is just shell variable assignments.
# Every option below is optional — delete or leave empty anything you don't need.
#
# Subtracting entries: any list variable below can be trimmed by declaring a
# companion <NAME>_REMOVE array (bash has no `-=` operator). This is most useful
# when a config builds on configs/default.sh, but it works here too. Example:
#   BREW_PACKAGES_REMOVE=( wireshark nmap )
#   BREW_CASKS_REMOVE=( spotify )
# Supported for: BREW_TAPS, BREW_PACKAGES(_ESSENTIAL), BREW_CASKS(_ESSENTIAL),
# MAS_APPS, NPM_PACKAGES, PIP_PACKAGES, GEM_PACKAGES, SDKMAN_CANDIDATES,
# MCP_SERVERS, INTELLIJ_DEFAULT_FOR, DOTFILES_FILES.
# -----------------------------------------------------------------------------

# === Homebrew taps =====================================================
# Extra package sources. Most setups need none.
BREW_TAPS=(
  # homebrew/cask-fonts
)

# Installation happens in two waves:
#   WAVE 1 (*_ESSENTIAL) is installed BEFORE the dotfiles — put here only what
#          you need to clone + link the dotfiles and get a usable shell.
#   WAVE 2 (BREW_PACKAGES / BREW_CASKS) is installed AFTER the dotfiles — all
#          the heavier and optional tools and apps.
# If you link dotfiles with stow, put `stow` in BREW_PACKAGES_ESSENTIAL.

# === WAVE 1: essential formulae + casks (installed first) ==============
BREW_PACKAGES_ESSENTIAL=(
  # git
  # stow
  # neovim
)
BREW_CASKS_ESSENTIAL=(
  # font-jetbrains-mono-nerd-font
)

# === WAVE 2: formulae (command-line tools) =============================
BREW_PACKAGES=(
  git
  fzf
  jq
  neovim
)

# === WAVE 2: casks (GUI applications) ==================================
# Find names at https://brew.sh or with `brew search <name>`.
BREW_CASKS=(
  # google-chrome
  # raycast
  # rectangle
  # visual-studio-code
)

# Subtract entries you don't want (handy when sourcing configs/default.sh).
# These companion arrays drop the named items from BREW_PACKAGES / BREW_CASKS.
BREW_PACKAGES_REMOVE=(
  # wireshark
)
BREW_CASKS_REMOVE=(
  # spotify
)

# Where casks install their .app bundles. Default: /Applications
CASK_APPDIR="/Applications"

# === Mac App Store apps ================================================
# Requires being signed into the App Store. Format per entry: "App Name|id"
# Get ids with `mas list` (installed) or `mas search "App Name"`.
# `mas` itself is installed automatically when this list is non-empty.
MAS_APPS=(
  # "Things 3|904280696"
)

# === Dotfiles ==========================================================
# The repo is cloned to DOTFILES_DEST, then each file in DOTFILES_FILES is
# symlinked from there into your $HOME (existing files are backed up first).
DOTFILES_REPO=""                          # e.g. git@github.com:you/dotfiles.git
DOTFILES_DEST="$HOME/repos/dotfiles"
DOTFILES_VERSION="main"                   # branch, tag, or commit
DOTFILES_ACCEPT_HOSTKEY=true              # auto-accept SSH host key on first clone

# Git submodules in the dotfiles repo are fetched automatically.

# How to link the dotfiles into $HOME:
#   "symlink" — link each file in DOTFILES_FILES individually (no extra tools).
#   "stow"    — use GNU Stow to link the whole repo, folding directories and
#               honoring the repo's .stow-local-ignore. Requires `stow` (add it
#               to BREW_PACKAGES). Best if your repo is built for stow.
DOTFILES_METHOD="symlink"
DOTFILES_STOW_TARGET="$HOME"              # stow target dir (only used for "stow")

# Only used when DOTFILES_METHOD="symlink":
DOTFILES_FILES=(
  # .zshrc
  # .gitconfig
  # .config
)

# === macOS defaults ====================================================
# A script (usually shipped in your dotfiles) that sets system preferences.
# Leave empty to skip. Arguments are allowed; ~ is expanded.
MACOS_SCRIPT=""                           # e.g. "$HOME/.osx --no-restart"

# Start with a completely empty Dock (removes all pinned apps). Opt-in.
CLEAR_DOCK=false

# === "Open in IntelliJ" Finder integration =============================
# Builds a small wrapper app so any file can be opened in IntelliJ's
# lightweight LightEdit mode via Finder's right-click "Open With" menu.
# Needs the IntelliJ cask installed (add it to BREW_CASKS).
INTELLIJ_OPENER=false                     # set true to create the opener app
INTELLIJ_APP_NAME="IntelliJ IDEA.app"     # "IntelliJ IDEA CE.app" for Community
INTELLIJ_OPENER_NAME="Open in IntelliJ"   # name shown in the Open With menu
INTELLIJ_OPENER_BUNDLE_ID="com.mac-setup.open-in-intellij"  # stable id for handlers
# Make the opener the *default* (double-click) app for these extensions.
# Needs `duti` (add it to BREW_PACKAGES). With/without leading dot both work.
INTELLIJ_DEFAULT_FOR=(
  # txt json xml yaml yml html css js ts md log csv
)

# === Optional language package managers ================================
# These run only if non-empty AND the relevant tool is installed.
NPM_PACKAGES=()                           # global npm installs
PIP_PACKAGES=()                           # installed via pipx if present, else pip3
GEM_PACKAGES=()                           # global gem installs

# SDKMAN candidates as "<candidate> <version>". Installs SDKMAN if missing, then
# runs `sdk install <candidate> <version>` for each. Empty by default.
SDKMAN_CANDIDATES=(
  # "java 17.0.19-amzn"
  # "maven 3.9.9"
)

# === Claude Code MCP (Model Context Protocol) servers ==================
# List the servers you want, then declare each with a block of MCP_<NAME>_*
# variables. Re-runs are safe — checkouts are pulled and registrations
# replaced. Secrets must be exported in your shell (typically by sourcing a
# gitignored secrets file from your .zshrc); they are NOT written into
# ~/.claude.json. If a required secret is missing and the script is running
# interactively, it prompts (input hidden) and appends an `export …` line to
# the secrets file. Set SECRETS_FILE to point at it (a generic var, not
# MCP-specific); defaults to "$DOTFILES_DEST/secrets.zsh".
SECRETS_FILE="$DOTFILES_DEST/secrets.zsh"
MCP_SERVERS=(
  # redmine
  # github
)

# --- Type: uv-git (clone, uv sync, uv tool install) -----------------------
# Good for Python MCP servers distributed as a source repo.
# MCP_REDMINE_TYPE="uv-git"
# MCP_REDMINE_REPO="https://github.com/snowild/redmine-mcp.git"
# MCP_REDMINE_DEST="$HOME/IdeaProjects/redmine-mcp"
# MCP_REDMINE_BIN="$HOME/.local/bin/redmine-mcp"
# MCP_REDMINE_PYTHON="3.12"                            # optional version pin
# MCP_REDMINE_ENV=("REDMINE_DOMAIN=https://redmine.example.com")
# MCP_REDMINE_REQUIRES=("REDMINE_API_KEY")             # must be exported

# --- Type: npx (no pre-install; child process runs `npx <pkg>`) -----------
# Common shape for official GitHub/GitLab MCP servers.
# MCP_GITHUB_TYPE="npx"
# MCP_GITHUB_PACKAGE="@modelcontextprotocol/server-github"
# MCP_GITHUB_NPX_ARGS=("-y")
# MCP_GITHUB_REQUIRES=("GITHUB_PERSONAL_ACCESS_TOKEN")

# --- Type: command (a binary already on PATH) -----------------------------
# MCP_FOO_TYPE="command"
# MCP_FOO_COMMAND="/usr/local/bin/some-mcp-server"
# MCP_FOO_ARGS=("--port" "0")
