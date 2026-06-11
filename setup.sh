#!/usr/bin/env bash
#
# mac-setup — bootstrap a fresh Mac from a single config file.
#
#   ./setup.sh <config-file> [--dry-run]
#
# Example:
#   ./setup.sh configs/jonas.sh
#   ./setup.sh configs/jonas.sh --dry-run    # preview, change nothing
#
# The config file is a plain shell file declaring what to install (see
# configs/example.sh for the full, documented contract). The script itself is
# generic and reusable — fork the repo, drop in your own configs/<you>.sh, run.

set -euo pipefail

# --- locate ourselves so the script works from any directory ---------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

usage() {
  cat <<'EOF'
Usage: ./setup.sh <config-file> [--dry-run]

  <config-file>   Path to a shell config file (e.g. configs/jonas.sh)
  --dry-run       Print every action without executing anything

See configs/example.sh for all available options.
EOF
}

# --- parse arguments --------------------------------------------------------
DRY_RUN=false
CONFIG_FILE=""
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    -h|--help) usage; exit 0 ;;
    -*)        echo "Unknown option: $arg" >&2; usage; exit 1 ;;
    *)         CONFIG_FILE="$arg" ;;
  esac
done
export DRY_RUN

if [ -z "$CONFIG_FILE" ]; then
  echo "Error: no config file given." >&2
  usage
  exit 1
fi
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: config file '$CONFIG_FILE' not found." >&2
  exit 1
fi

# --- sane defaults so a config can omit anything it doesn't use -------------
BREW_TAPS=() BREW_PACKAGES=() BREW_CASKS=() MAS_APPS=()
BREW_PACKAGES_ESSENTIAL=() BREW_CASKS_ESSENTIAL=()
CASK_APPDIR="/Applications"
DOTFILES_REPO="" DOTFILES_DEST="$HOME/repos/dotfiles" DOTFILES_VERSION="main"
DOTFILES_ACCEPT_HOSTKEY=false DOTFILES_FILES=()
DOTFILES_METHOD="symlink" DOTFILES_STOW_TARGET="$HOME"
MACOS_SCRIPT="" CLEAR_DOCK=false
NPM_PACKAGES=() PIP_PACKAGES=() GEM_PACKAGES=() SDKMAN_CANDIDATES=()
INTELLIJ_OPENER=false INTELLIJ_APP_NAME="IntelliJ IDEA.app"
INTELLIJ_OPENER_NAME="Open in IntelliJ"
INTELLIJ_OPENER_BUNDLE_ID="com.mac-setup.open-in-intellij"
INTELLIJ_DEFAULT_FOR=()

# --- load config + libraries ------------------------------------------------
# shellcheck source=/dev/null
source "$CONFIG_FILE"
# shellcheck source=lib/log.sh
source "$SCRIPT_DIR/lib/log.sh"
# shellcheck source=lib/homebrew.sh
source "$SCRIPT_DIR/lib/homebrew.sh"
# shellcheck source=lib/dotfiles.sh
source "$SCRIPT_DIR/lib/dotfiles.sh"
# shellcheck source=lib/macos.sh
source "$SCRIPT_DIR/lib/macos.sh"
# shellcheck source=lib/packages.sh
source "$SCRIPT_DIR/lib/packages.sh"
# shellcheck source=lib/intellij.sh
source "$SCRIPT_DIR/lib/intellij.sh"

# Shared timestamp for any backups made during this run.
BACKUP_STAMP="$(date +%Y%m%d-%H%M%S)"

# --- helpful error trap -----------------------------------------------------
trap 'error "Failed at line $LINENO. Setup aborted."' ERR

# --- run --------------------------------------------------------------------
printf '%s%s\n' "$_C_BOLD" "mac-setup — using config: $CONFIG_FILE"
[ "$DRY_RUN" = "true" ] && warn "DRY RUN: no changes will be made."

ensure_homebrew

# Wave 1: essentials needed to install and use the dotfiles.
install_homebrew_essential

# Dotfiles + macOS settings, now that the essentials (e.g. stow) are present.
clone_dotfiles
link_dotfiles
run_macos_script
clear_dock

# Wave 2: the heavier / optional tools and apps.
install_homebrew_main

# "Open in IntelliJ" Finder integration (needs the IntelliJ cask from wave 2).
install_intellij_opener
set_intellij_default_handlers

# Language packages depend on tools from wave 2 (node, pipx, ...).
install_language_packages

section "Done"
info "Setup complete for config: $CONFIG_FILE"
if [ -d "$HOME/.mac-setup-backups/$BACKUP_STAMP" ]; then
  info "Files that were replaced are backed up in: $HOME/.mac-setup-backups/$BACKUP_STAMP"
fi
info "You may need to restart your shell (or your Mac) for all changes to take effect."
