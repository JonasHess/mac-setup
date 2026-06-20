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
  cyberduck
  dbeaver-community
  docker-desktop
  drawio
  elgato-camera-hub
  firefox
  gcloud-cli
  handbrake-app
  hiddenbar
  intellij-idea
  iterm2
  kdiff3
  keepassxc
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
# Secrets (REDMINE_API_KEY, PUBX_DATABASE_URI, ...) live in $SECRETS_FILE
# under oh-my-zsh's custom dir, where oh-my-zsh auto-sources every *.zsh file
# on shell start. They are forwarded into the MCP server's env via
# MCP_<N>_REQUIRES; never written into the Claude Code config. See lib/mcp.sh
# for the full contract.
SECRETS_FILE="$DOTFILES_DEST/.oh-my-zsh/custom/secrets.zsh"
MCP_SERVERS=(
  redmine
  postgres
  postgres-staging
  postgres-sandbox
  postgres-mds
  postgres-mds-staging
  postgres-mds-sandbox
  postgres-assets
  postgres-assets-staging
  postgres-assets-sandbox
  gitlab
)

# --- redmine: MVB Redmine at pm.dev.booklan.de (snowild/redmine-mcp) -----
MCP_REDMINE_TYPE="uv-git"
MCP_REDMINE_REPO="https://github.com/snowild/redmine-mcp.git"
MCP_REDMINE_DEST="$HOME/IdeaProjects/redmine-mcp"
MCP_REDMINE_BIN="$HOME/.local/bin/redmine-mcp"
MCP_REDMINE_PYTHON="3.12"
MCP_REDMINE_ENV=("REDMINE_DOMAIN=https://pm.dev.booklan.de")
MCP_REDMINE_REQUIRES=("REDMINE_API_KEY")

# --- postgres: local Docker postgres "pubx" (crystaldba/postgres-mcp) -----
# Unrestricted mode (writes allowed) — drop the --access-mode flag from ARGS
# for read-only. Connection URI lives in $SECRETS_FILE as PUBX_DATABASE_URI
# (e.g. postgresql://postgres:password@localhost:5432/pubx) and is forwarded
# to the MCP server as DATABASE_URI via the REQUIRES rename syntax.
MCP_POSTGRES_TYPE="uv-git"
MCP_POSTGRES_REPO="https://github.com/crystaldba/postgres-mcp.git"
MCP_POSTGRES_DEST="$HOME/IdeaProjects/postgres-mcp"
MCP_POSTGRES_BIN="$HOME/.local/bin/postgres-mcp"
MCP_POSTGRES_PYTHON="3.12"
MCP_POSTGRES_REQUIRES=("DATABASE_URI=PUBX_DATABASE_URI")
MCP_POSTGRES_ARGS=("--access-mode=unrestricted")

# --- postgres-staging: shared staging pubx DB (read-only) ---------------
# Reuses the postgres-mcp binary installed by the `postgres` server above —
# only the DATABASE_URI env and access mode differ. Connection URI lives in
# $SECRETS_FILE as PUBX_STAGING_DATABASE_URI.
MCP_POSTGRES_STAGING_TYPE="uv-git"
MCP_POSTGRES_STAGING_REPO="https://github.com/crystaldba/postgres-mcp.git"
MCP_POSTGRES_STAGING_DEST="$HOME/IdeaProjects/postgres-mcp"
MCP_POSTGRES_STAGING_BIN="$HOME/.local/bin/postgres-mcp"
MCP_POSTGRES_STAGING_PYTHON="3.12"
MCP_POSTGRES_STAGING_REQUIRES=("DATABASE_URI=PUBX_STAGING_DATABASE_URI")
MCP_POSTGRES_STAGING_ARGS=("--access-mode=restricted")

# --- postgres-sandbox: shared sandbox pubx DB (read-only) ---------------
# Reuses the postgres-mcp binary installed by the `postgres` server above —
# only the DATABASE_URI env and access mode differ. Connection URI lives in
# $SECRETS_FILE as PUBX_SANDBOX_DATABASE_URI.
MCP_POSTGRES_SANDBOX_TYPE="uv-git"
MCP_POSTGRES_SANDBOX_REPO="https://github.com/crystaldba/postgres-mcp.git"
MCP_POSTGRES_SANDBOX_DEST="$HOME/IdeaProjects/postgres-mcp"
MCP_POSTGRES_SANDBOX_BIN="$HOME/.local/bin/postgres-mcp"
MCP_POSTGRES_SANDBOX_PYTHON="3.12"
MCP_POSTGRES_SANDBOX_REQUIRES=("DATABASE_URI=PUBX_SANDBOX_DATABASE_URI")
MCP_POSTGRES_SANDBOX_ARGS=("--access-mode=restricted")

# --- postgres-mds: local Docker postgres "mds" DB (crystaldba/postgres-mcp) -
# `mds` is a separate database on the same instance/credentials as pubx — only
# the database name in the connection URI differs. Reuses the postgres-mcp
# binary installed by the `postgres` server above. Connection URI lives in
# $SECRETS_FILE as MDS_DATABASE_URI (e.g.
# postgresql://postgres:password@localhost:5432/mds).
MCP_POSTGRES_MDS_TYPE="uv-git"
MCP_POSTGRES_MDS_REPO="https://github.com/crystaldba/postgres-mcp.git"
MCP_POSTGRES_MDS_DEST="$HOME/IdeaProjects/postgres-mcp"
MCP_POSTGRES_MDS_BIN="$HOME/.local/bin/postgres-mcp"
MCP_POSTGRES_MDS_PYTHON="3.12"
MCP_POSTGRES_MDS_REQUIRES=("DATABASE_URI=MDS_DATABASE_URI")
MCP_POSTGRES_MDS_ARGS=("--access-mode=unrestricted")

# --- postgres-mds-staging: shared staging mds DB (read-only) ------------
# Connection URI lives in $SECRETS_FILE as MDS_STAGING_DATABASE_URI.
MCP_POSTGRES_MDS_STAGING_TYPE="uv-git"
MCP_POSTGRES_MDS_STAGING_REPO="https://github.com/crystaldba/postgres-mcp.git"
MCP_POSTGRES_MDS_STAGING_DEST="$HOME/IdeaProjects/postgres-mcp"
MCP_POSTGRES_MDS_STAGING_BIN="$HOME/.local/bin/postgres-mcp"
MCP_POSTGRES_MDS_STAGING_PYTHON="3.12"
MCP_POSTGRES_MDS_STAGING_REQUIRES=("DATABASE_URI=MDS_STAGING_DATABASE_URI")
MCP_POSTGRES_MDS_STAGING_ARGS=("--access-mode=restricted")

# --- postgres-mds-sandbox: shared sandbox mds DB (read-only) ------------
# Connection URI lives in $SECRETS_FILE as MDS_SANDBOX_DATABASE_URI.
MCP_POSTGRES_MDS_SANDBOX_TYPE="uv-git"
MCP_POSTGRES_MDS_SANDBOX_REPO="https://github.com/crystaldba/postgres-mcp.git"
MCP_POSTGRES_MDS_SANDBOX_DEST="$HOME/IdeaProjects/postgres-mcp"
MCP_POSTGRES_MDS_SANDBOX_BIN="$HOME/.local/bin/postgres-mcp"
MCP_POSTGRES_MDS_SANDBOX_PYTHON="3.12"
MCP_POSTGRES_MDS_SANDBOX_REQUIRES=("DATABASE_URI=MDS_SANDBOX_DATABASE_URI")
MCP_POSTGRES_MDS_SANDBOX_ARGS=("--access-mode=restricted")

# --- postgres-assets: local Docker postgres "assets" DB ------------------
# `assets` (plural) is a separate database on the same instance/credentials as
# pubx. Connection URI lives in $SECRETS_FILE as ASSETS_DATABASE_URI (e.g.
# postgresql://postgres:password@localhost:5432/assets).
MCP_POSTGRES_ASSETS_TYPE="uv-git"
MCP_POSTGRES_ASSETS_REPO="https://github.com/crystaldba/postgres-mcp.git"
MCP_POSTGRES_ASSETS_DEST="$HOME/IdeaProjects/postgres-mcp"
MCP_POSTGRES_ASSETS_BIN="$HOME/.local/bin/postgres-mcp"
MCP_POSTGRES_ASSETS_PYTHON="3.12"
MCP_POSTGRES_ASSETS_REQUIRES=("DATABASE_URI=ASSETS_DATABASE_URI")
MCP_POSTGRES_ASSETS_ARGS=("--access-mode=unrestricted")

# --- postgres-assets-staging: shared staging assets DB (read-only) ------
# Connection URI lives in $SECRETS_FILE as ASSETS_STAGING_DATABASE_URI.
MCP_POSTGRES_ASSETS_STAGING_TYPE="uv-git"
MCP_POSTGRES_ASSETS_STAGING_REPO="https://github.com/crystaldba/postgres-mcp.git"
MCP_POSTGRES_ASSETS_STAGING_DEST="$HOME/IdeaProjects/postgres-mcp"
MCP_POSTGRES_ASSETS_STAGING_BIN="$HOME/.local/bin/postgres-mcp"
MCP_POSTGRES_ASSETS_STAGING_PYTHON="3.12"
MCP_POSTGRES_ASSETS_STAGING_REQUIRES=("DATABASE_URI=ASSETS_STAGING_DATABASE_URI")
MCP_POSTGRES_ASSETS_STAGING_ARGS=("--access-mode=restricted")

# --- postgres-assets-sandbox: shared sandbox assets DB (read-only) ------
# Connection URI lives in $SECRETS_FILE as ASSETS_SANDBOX_DATABASE_URI.
MCP_POSTGRES_ASSETS_SANDBOX_TYPE="uv-git"
MCP_POSTGRES_ASSETS_SANDBOX_REPO="https://github.com/crystaldba/postgres-mcp.git"
MCP_POSTGRES_ASSETS_SANDBOX_DEST="$HOME/IdeaProjects/postgres-mcp"
MCP_POSTGRES_ASSETS_SANDBOX_BIN="$HOME/.local/bin/postgres-mcp"
MCP_POSTGRES_ASSETS_SANDBOX_PYTHON="3.12"
MCP_POSTGRES_ASSETS_SANDBOX_REQUIRES=("DATABASE_URI=ASSETS_SANDBOX_DATABASE_URI")
MCP_POSTGRES_ASSETS_SANDBOX_ARGS=("--access-mode=restricted")

# --- gitlab: self-hosted MVB GitLab (zereight/mcp-gitlab, read-only) -----
# Read-only mode: list/read projects, MRs, issues, files. Drop the
# GITLAB_READ_ONLY_MODE env entry to allow writes. PAT lives in $SECRETS_FILE
# as GITLAB_PERSONAL_ACCESS_TOKEN and is auto-forwarded under the same name.
MCP_GITLAB_TYPE="npx"
MCP_GITLAB_PACKAGE="@zereight/mcp-gitlab"
MCP_GITLAB_NPX_ARGS=("-y")
MCP_GITLAB_ENV=(
  "GITLAB_API_URL=https://gitlab.dev.booklan.de/api/v4"
  "GITLAB_READ_ONLY_MODE=true"
)
MCP_GITLAB_REQUIRES=("GITLAB_PERSONAL_ACCESS_TOKEN")
