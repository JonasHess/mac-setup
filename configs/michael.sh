#!/usr/bin/env bash
#
# Jonas's mac-setup config.   Run:  ./setup.sh configs/jonas.sh
# See configs/example.sh for documentation of every option.
# -----------------------------------------------------------------------------

# === Homebrew taps =====================================================
# (homebrew/cask-fonts was deprecated/removed — nerd fonts live in core now.)
BREW_TAPS=()

# === WAVE 1: essentials (installed BEFORE the dotfiles) ================
# Just enough to clone + stow the dotfiles and get a working shell/prompt.
BREW_PACKAGES_ESSENTIAL=(
  git                      # clone the dotfiles repo
  stow                     # symlink the dotfiles into $HOME
  zsh                      # the shell the dotfiles configure
  zsh-syntax-highlighting
  neovim                   # .nvimrc
  tmux                     # .tmux.conf
  fzf
)
BREW_CASKS_ESSENTIAL=(
  font-jetbrains-mono-nerd-font   # glyphs for the powerlevel10k prompt
)

# === WAVE 2: everything else (installed AFTER the dotfiles) ============
# Heavier and optional tools and CLI utilities.
BREW_PACKAGES=(
  ansible
  argocd
  argocd-autopilot
  atool
  autoconf
  awscli
  azure-cli
  bash
  bash-completion
  bat
  curl
  doxygen
  duti
  fblog
  ffmpeg
  gettext
  gh
  gifsicle
  go
  gpg
  helm
  highlight
  htop
  httpie
  iperf
  istioctl
  jenv
  jq
  k9s
  kubecm
  kubectx
  kubernetes-cli
  lazydocker
  lazygit
  less
  lf
  libevent
  fastfetch
  nmap
  node
  nvm
  openssl
  php
  pipx
  postgresql@18
  pre-commit
  putty
  ranger
  rclone
  rust
  sevenzip
  speedtest-cli
  sqlite
  ssh-copy-id
  tldr
  toilet
  tree-sitter
  unar
  util-linux
  uv                       # Python toolchain — needed by uv-git MCP servers
  wget
  wireshark
  yarn
  yq
  zellij
)

# === Homebrew casks (GUI applications) =================================
BREW_CASKS=(
  alacritty
  alt-tab
  appcleaner
  camunda-modeler
  chromium
  dbeaver-community
  docker-desktop
  drawio
  firefox
  gcloud-cli
  handbrake-app
  hiddenbar
  intellij-idea
  jabra-direct
  iterm2
  kdiff3
  keepassxc
  licecap
  logi-options+
  nordvpn
  pycharm
  raycast
  rectangle
  royal-tsx
  sequel-ace
  skim
  slack
  soapui
  spotify
  transmit
  visual-studio-code
  vlc
  whatsapp
  # amazon-photos
  # chromedriver
  # google-chrome
)

CASK_APPDIR="/Applications"

# === Mac App Store apps ================================================
MAS_APPS=()

# === Dotfiles ==========================================================
DOTFILES_REPO="git@github.com:zimmermq/dotfiles.git"
DOTFILES_DEST="$HOME/IdeaProjects/dotfiles"
DOTFILES_VERSION="main"
DOTFILES_ACCEPT_HOSTKEY=true

# This repo is built for GNU Stow (it has a .stow-local-ignore). Stow links the
# whole repo into $HOME, folding directories. `stow` is in BREW_PACKAGES above.
DOTFILES_METHOD="stow"
DOTFILES_STOW_TARGET="$HOME"

# Only used if DOTFILES_METHOD="symlink". Kept for reference.
DOTFILES_FILES=(
  .gitconfig
  .gitignore
  .inputrc
  .nvimrc
  .oh-my-zsh
  .osx
  .p10k.zsh
  .tmux.conf
  .tmux.conf.local
  .config
  .zshrc
)

# === macOS defaults ====================================================
MACOS_SCRIPT="$HOME/.osx --no-restart"

# Flip to true on a device where you want to start with an empty Dock.
CLEAR_DOCK=false

# === "Open in IntelliJ" Finder integration =============================
# Right-click any file → Open With → "Open in IntelliJ" (LightEdit mode).
# Using the full (non-Community) edition, so the default app name is correct.
INTELLIJ_OPENER=true

# Make the opener the default (double-click) app for these text-ish types.
# Requires `duti` (in BREW_PACKAGES above).
INTELLIJ_DEFAULT_FOR=(
  txt json xml edi html htm
  yaml yml csv tsv log md
  ini conf cfg properties toml
  js ts css sql sh
)


# === Optional language package managers ================================
NPM_PACKAGES=()
PIP_PACKAGES=()
GEM_PACKAGES=()

# SDKMAN candidates ("<candidate> <version>"). Installs SDKMAN if missing.
SDKMAN_CANDIDATES=(
  "java 25.0.3-amzn"
  "maven 3.9.16"
)

# === Claude Code MCP servers ===========================================
# Secrets (REDMINE_API_KEY, ...) are exported from dotfiles/secrets.zsh —
# never written to ~/.claude.json. See lib/mcp.sh for the full contract.
MCP_SERVERS=(
  redmine
)

# --- redmine: MVB Redmine at pm.dev.booklan.de (snowild/redmine-mcp) -----
MCP_REDMINE_TYPE="uv-git"
MCP_REDMINE_REPO="https://github.com/snowild/redmine-mcp.git"
MCP_REDMINE_DEST="$HOME/IdeaProjects/redmine-mcp"
MCP_REDMINE_BIN="$HOME/.local/bin/redmine-mcp"
MCP_REDMINE_PYTHON="3.12"
MCP_REDMINE_ENV=("REDMINE_DOMAIN=https://pm.dev.booklan.de")
MCP_REDMINE_REQUIRES=("REDMINE_API_KEY")
