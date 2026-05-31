#!/usr/bin/env bash
#
# Example config for mac-setup. Copy this to configs/<your-name-or-host>.sh,
# edit it, then run:  ./setup.sh configs/<your-name-or-host>.sh
#
# This file is `source`d by setup.sh, so it is just shell variable assignments.
# Every option below is optional — delete or leave empty anything you don't need.
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

# === Optional language package managers ================================
# These run only if non-empty AND the relevant tool is installed.
NPM_PACKAGES=()                           # global npm installs
PIP_PACKAGES=()                           # installed via pipx if present, else pip3
GEM_PACKAGES=()                           # global gem installs
