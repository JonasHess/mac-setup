#!/usr/bin/env bash
#
# Shared default config for mac-setup. NOT run directly — it is `source`d by a
# per-person config (e.g. configs/jonas.sh, configs/michael.sh) that overrides
# the few machine-/person-specific bits.
#
# How the layering works:
#   1. The per-person config sets its personal IDENTITY scalars first —
#      DOTFILES_REPO and DOTFILES_DEST. These are read here via ${VAR:-fallback}
#      so the preset wins, and SECRETS_FILE is derived from DOTFILES_DEST, which
#      is why DEST must be set *before* this file is sourced.
#   2. This file fills in everything shared (arrays + the rest of the scalars).
#      Shared scalars are assigned directly (NOT ${VAR:-...}): setup.sh pre-seeds
#      its own defaults before sourcing a config, so a plain `:-` would keep
#      setup.sh's value (e.g. DOTFILES_METHOD=symlink) instead of ours.
#   3. The per-person config then APPENDS its extra apps (BREW_CASKS+=( ... )),
#      SUBTRACTS defaults it doesn't want (BREW_CASKS_REMOVE=( ... )), or
#      re-assigns any shared scalar to override it — all *after* sourcing this
#      file. The _REMOVE companions are applied by lib/config.sh once the whole
#      config is sourced.
#
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
# Heavier and optional tools and CLI utilities. Append per-person extras with
# BREW_PACKAGES+=( ... ) in the sourcing config.
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
# Append per-person extras with BREW_CASKS+=( ... ) in the sourcing config.
BREW_CASKS=(
  alacritty
  alt-tab
  appcleaner
  camunda-modeler
  ungoogled-chromium
  cyberduck
  dbeaver-community
  docker-desktop
  drawio
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
# Personal: set DOTFILES_REPO (and DOTFILES_DEST if you don't use the default)
# in your per-person config BEFORE sourcing this file. The ${VAR:-...} form
# below keeps whatever you preset and otherwise falls back.
DOTFILES_REPO="${DOTFILES_REPO:-}"                       # e.g. git@github.com:you/dotfiles.git
DOTFILES_DEST="${DOTFILES_DEST:-$HOME/repos/dotfiles}"
DOTFILES_VERSION="main"
DOTFILES_ACCEPT_HOSTKEY=true

# This repo is built for GNU Stow (it has a .stow-local-ignore). Stow links the
# whole repo into $HOME, folding directories. `stow` is in BREW_PACKAGES_ESSENTIAL.
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
# for the full contract. Derived from DOTFILES_DEST, so set that first.
SECRETS_FILE="${SECRETS_FILE:-$DOTFILES_DEST/.oh-my-zsh/custom/secrets.zsh}"
MCP_SERVERS=(
  redmine
  postgres-pubx-local
  postgres-pubx-staging
  postgres-pubx-sandbox
  postgres-pubx-prod
  postgres-mds-local
  postgres-mds-staging
  postgres-mds-sandbox
  postgres-mds-prod
  postgres-assets-local
  postgres-assets-staging
  postgres-assets-sandbox
  postgres-assets-prod
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

# --- postgres-pubx-local: local Docker postgres "pubx" (crystaldba/postgres-mcp) -----
# Unrestricted mode (writes allowed) — drop the --access-mode flag from ARGS
# for read-only. Connection URI lives in $SECRETS_FILE as PUBX_DATABASE_URI
# (e.g. postgresql://postgres:password@localhost:5432/pubx) and is forwarded
# to the MCP server as DATABASE_URI via the REQUIRES rename syntax.
MCP_POSTGRES_PUBX_LOCAL_TYPE="uv-git"
MCP_POSTGRES_PUBX_LOCAL_REPO="https://github.com/crystaldba/postgres-mcp.git"
MCP_POSTGRES_PUBX_LOCAL_DEST="$HOME/IdeaProjects/postgres-mcp"
MCP_POSTGRES_PUBX_LOCAL_BIN="$HOME/.local/bin/postgres-mcp"
MCP_POSTGRES_PUBX_LOCAL_PYTHON="3.12"
MCP_POSTGRES_PUBX_LOCAL_REQUIRES=("DATABASE_URI=PUBX_DATABASE_URI")
MCP_POSTGRES_PUBX_LOCAL_ARGS=("--access-mode=unrestricted")

# --- postgres-pubx-staging: shared staging pubx DB (read-only) ---------------
# Reuses the postgres-mcp binary installed by the pubx-local server above —
# only the DATABASE_URI env and access mode differ. Connection URI lives in
# $SECRETS_FILE as PUBX_STAGING_DATABASE_URI.
MCP_POSTGRES_PUBX_STAGING_TYPE="uv-git"
MCP_POSTGRES_PUBX_STAGING_REPO="https://github.com/crystaldba/postgres-mcp.git"
MCP_POSTGRES_PUBX_STAGING_DEST="$HOME/IdeaProjects/postgres-mcp"
MCP_POSTGRES_PUBX_STAGING_BIN="$HOME/.local/bin/postgres-mcp"
MCP_POSTGRES_PUBX_STAGING_PYTHON="3.12"
MCP_POSTGRES_PUBX_STAGING_REQUIRES=("DATABASE_URI=PUBX_STAGING_DATABASE_URI")
MCP_POSTGRES_PUBX_STAGING_ARGS=("--access-mode=restricted")

# --- postgres-pubx-sandbox: shared sandbox pubx DB (read-only) ---------------
# Reuses the postgres-mcp binary installed by the pubx-local server above —
# only the DATABASE_URI env and access mode differ. Connection URI lives in
# $SECRETS_FILE as PUBX_SANDBOX_DATABASE_URI.
MCP_POSTGRES_PUBX_SANDBOX_TYPE="uv-git"
MCP_POSTGRES_PUBX_SANDBOX_REPO="https://github.com/crystaldba/postgres-mcp.git"
MCP_POSTGRES_PUBX_SANDBOX_DEST="$HOME/IdeaProjects/postgres-mcp"
MCP_POSTGRES_PUBX_SANDBOX_BIN="$HOME/.local/bin/postgres-mcp"
MCP_POSTGRES_PUBX_SANDBOX_PYTHON="3.12"
MCP_POSTGRES_PUBX_SANDBOX_REQUIRES=("DATABASE_URI=PUBX_SANDBOX_DATABASE_URI")
MCP_POSTGRES_PUBX_SANDBOX_ARGS=("--access-mode=restricted")

# --- postgres-pubx-prod: shared prod pubx DB (read-only) ---------------------
# Reuses the postgres-mcp binary installed by the pubx-local server above —
# only the DATABASE_URI env and access mode differ. Restricted (read-only)
# since it points at production (host pubx-prod-db2.cloud.gcp). Connection URI
# lives in $SECRETS_FILE as PUBX_PROD_DATABASE_URI.
MCP_POSTGRES_PUBX_PROD_TYPE="uv-git"
MCP_POSTGRES_PUBX_PROD_REPO="https://github.com/crystaldba/postgres-mcp.git"
MCP_POSTGRES_PUBX_PROD_DEST="$HOME/IdeaProjects/postgres-mcp"
MCP_POSTGRES_PUBX_PROD_BIN="$HOME/.local/bin/postgres-mcp"
MCP_POSTGRES_PUBX_PROD_PYTHON="3.12"
MCP_POSTGRES_PUBX_PROD_REQUIRES=("DATABASE_URI=PUBX_PROD_DATABASE_URI")
MCP_POSTGRES_PUBX_PROD_ARGS=("--access-mode=restricted")

# --- postgres-mds-local: local Docker postgres "mds" DB (crystaldba/postgres-mcp) -
# `mds` is a separate database on the same instance/credentials as pubx — only
# the database name in the connection URI differs. Reuses the postgres-mcp
# binary installed by the pubx-local server above. Connection URI lives in
# $SECRETS_FILE as MDS_DATABASE_URI (e.g.
# postgresql://postgres:password@localhost:5432/mds).
MCP_POSTGRES_MDS_LOCAL_TYPE="uv-git"
MCP_POSTGRES_MDS_LOCAL_REPO="https://github.com/crystaldba/postgres-mcp.git"
MCP_POSTGRES_MDS_LOCAL_DEST="$HOME/IdeaProjects/postgres-mcp"
MCP_POSTGRES_MDS_LOCAL_BIN="$HOME/.local/bin/postgres-mcp"
MCP_POSTGRES_MDS_LOCAL_PYTHON="3.12"
MCP_POSTGRES_MDS_LOCAL_REQUIRES=("DATABASE_URI=MDS_DATABASE_URI")
MCP_POSTGRES_MDS_LOCAL_ARGS=("--access-mode=unrestricted")

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

# --- postgres-mds-prod: shared prod mds DB (read-only) ------------------
# Restricted (read-only) since it points at production (host
# pubx-prod-db2.cloud.gcp). Connection URI lives in $SECRETS_FILE as
# MDS_PROD_DATABASE_URI.
MCP_POSTGRES_MDS_PROD_TYPE="uv-git"
MCP_POSTGRES_MDS_PROD_REPO="https://github.com/crystaldba/postgres-mcp.git"
MCP_POSTGRES_MDS_PROD_DEST="$HOME/IdeaProjects/postgres-mcp"
MCP_POSTGRES_MDS_PROD_BIN="$HOME/.local/bin/postgres-mcp"
MCP_POSTGRES_MDS_PROD_PYTHON="3.12"
MCP_POSTGRES_MDS_PROD_REQUIRES=("DATABASE_URI=MDS_PROD_DATABASE_URI")
MCP_POSTGRES_MDS_PROD_ARGS=("--access-mode=restricted")

# --- postgres-assets-local: local Docker postgres "assets" DB ------------------
# `assets` (plural) is a separate database on the same instance/credentials as
# pubx. Connection URI lives in $SECRETS_FILE as ASSETS_DATABASE_URI (e.g.
# postgresql://postgres:password@localhost:5432/assets).
MCP_POSTGRES_ASSETS_LOCAL_TYPE="uv-git"
MCP_POSTGRES_ASSETS_LOCAL_REPO="https://github.com/crystaldba/postgres-mcp.git"
MCP_POSTGRES_ASSETS_LOCAL_DEST="$HOME/IdeaProjects/postgres-mcp"
MCP_POSTGRES_ASSETS_LOCAL_BIN="$HOME/.local/bin/postgres-mcp"
MCP_POSTGRES_ASSETS_LOCAL_PYTHON="3.12"
MCP_POSTGRES_ASSETS_LOCAL_REQUIRES=("DATABASE_URI=ASSETS_DATABASE_URI")
MCP_POSTGRES_ASSETS_LOCAL_ARGS=("--access-mode=unrestricted")

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

# --- postgres-assets-prod: shared prod assets DB (read-only) ------------
# Restricted (read-only) since it points at production (host
# pubx-prod-db2.cloud.gcp). Connection URI lives in $SECRETS_FILE as
# ASSETS_PROD_DATABASE_URI.
MCP_POSTGRES_ASSETS_PROD_TYPE="uv-git"
MCP_POSTGRES_ASSETS_PROD_REPO="https://github.com/crystaldba/postgres-mcp.git"
MCP_POSTGRES_ASSETS_PROD_DEST="$HOME/IdeaProjects/postgres-mcp"
MCP_POSTGRES_ASSETS_PROD_BIN="$HOME/.local/bin/postgres-mcp"
MCP_POSTGRES_ASSETS_PROD_PYTHON="3.12"
MCP_POSTGRES_ASSETS_PROD_REQUIRES=("DATABASE_URI=ASSETS_PROD_DATABASE_URI")
MCP_POSTGRES_ASSETS_PROD_ARGS=("--access-mode=restricted")

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
