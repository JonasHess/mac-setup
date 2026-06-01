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
  colima
  curl
  docker
  docker-compose
  doxygen
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
  maven
  nmap
  node
  nvm
  openssl
  php
  pipx
  postgresql@18
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
  chromium
  dbeaver-community
  drawio
  elgato-camera-hub
  firefox
  gcloud-cli
  handbrake-app
  hiddenbar
  intellij-idea
  kdiff3
  licecap
  logi-options+
  microsoft-edge
  microsoft-office
  microsoft-remote-desktop
  microsoft-teams
  nordvpn
  pycharm
  raycast
  rectangle
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
DOTFILES_REPO="git@github.com:JonasHess/dotfiles.git"
DOTFILES_DEST="$HOME/repos/dotfiles"
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

# === Optional language package managers ================================
NPM_PACKAGES=()
PIP_PACKAGES=()
GEM_PACKAGES=()

# SDKMAN candidates ("<candidate> <version>"). Installs SDKMAN if missing.
SDKMAN_CANDIDATES=(
  "java 17.0.19-amzn"
)
