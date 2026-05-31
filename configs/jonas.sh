#!/usr/bin/env bash
#
# Jonas's mac-setup config.   Run:  ./setup.sh configs/jonas.sh
# See configs/example.sh for documentation of every option.
# -----------------------------------------------------------------------------

# === Homebrew taps =====================================================
BREW_TAPS=(
  homebrew/cask-fonts
)

# === Homebrew formulae (command-line tools) ============================
BREW_PACKAGES=(
  ansible
  argocd
  argocd-autopilot
  atool
  autoconf
  awscli
  azure-cli
  bash-completion
  bat
  curl
  doxygen
  fblog
  ffmpeg
  fzf
  gettext
  gh
  gifsicle
  git
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
  kubernetes-cli
  lazydocker
  lazygit
  less
  lf
  libevent
  neofetch
  neovim
  nmap
  node
  nvm
  openssl
  php
  pipx
  ranger
  rclone
  rust
  sevenzip
  speedtest-cli
  sqlite
  ssh-copy-id
  stow
  tldr
  tmux
  toilet
  tree-sitter
  unar
  util-linux
  wget
  wireshark
  yarn
  yq
  zellij
  zsh
  zsh-syntax-highlighting
)

# === Homebrew casks (GUI applications) =================================
BREW_CASKS=(
  adobe-acrobat-reader
  alacritty
  bitwarden
  brave-browser
  chromium
  dbeaver-community
  docker
  drawio
  elgato-camera-hub
  firefox
  font-jetbrains-mono-nerd-font
  google-cloud-sdk
  handbrake
  intellij-idea
  kdiff3
  licecap
  logi-options-plus
  microsoft-edge
  microsoft-office
  microsoft-remote-desktop
  microsoft-teams
  nordvpn
  pycharm
  raycast
  rectangle
  sequel-ace
  slack
  spotify
  sublime-text
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
