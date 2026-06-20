#!/usr/bin/env bash
#
# Michael's mac-setup config.   Run:  ./setup.sh configs/michael.sh
#
# Almost everything lives in configs/default.sh. This file only declares
# Michael's personal bits: the dotfiles repo and a few extra apps. See default.sh
# for the layering rules and configs/example.sh for documentation of every option.
# -----------------------------------------------------------------------------

# 1. Personal scalars — set BEFORE sourcing default.sh (SECRETS_FILE is derived
#    from DOTFILES_DEST in there).
DOTFILES_REPO="git@github.com:zimmermq/dotfiles.git"
DOTFILES_DEST="$HOME/IdeaProjects/dotfiles"

# 2. Shared defaults.
# shellcheck source=configs/default.sh
source "$(dirname "${BASH_SOURCE[0]}")/default.sh"

# 3. Personal extras — appended AFTER sourcing default.sh.
BREW_PACKAGES+=(
)
BREW_CASKS+=(
  jabra-direct
)

# Drop defaults you don't want (counterpart to += above). Works on any list
# array — append _REMOVE to its name. E.g.:
# BREW_PACKAGES_REMOVE=(
#   wireshark
# )
# BREW_CASKS_REMOVE=(
#   spotify
#   whatsapp
# )
