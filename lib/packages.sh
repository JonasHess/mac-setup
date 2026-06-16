#!/usr/bin/env bash
# Optional language package managers. Each runs only if its array is non-empty
# and the corresponding tool is available. Empty by default.

install_language_packages() {
  _ensure_nvm_dir
  _install_npm_packages
  _install_pip_packages
  _install_gem_packages
  _install_sdkman_candidates
}

# nvm (Homebrew formula) ships no data dir — the user must create one and point
# NVM_DIR at it before `nvm install` works. The dotfiles set
# NVM_DIR=$HOME/.config/nvm, so honour that if exported, else fall back to it.
_ensure_nvm_dir() {
  command -v brew >/dev/null 2>&1 || return 0
  brew list --formula nvm >/dev/null 2>&1 || return 0
  local nvm_dir="${NVM_DIR:-$HOME/.config/nvm}"
  [ -d "$nvm_dir" ] && return 0
  info "Creating NVM_DIR at $nvm_dir"
  run mkdir -p "$nvm_dir"
}

# SDKMAN candidates (e.g. "java 17.0.19-amzn"). Installs SDKMAN if missing, then
# `sdk install <candidate> <version>` for each entry. Empty by default.
_install_sdkman_candidates() {
  [ "${#SDKMAN_CANDIDATES[@]}" -gt 0 ] || return 0
  section "Installing SDKMAN candidates"

  # Snapshot the config's list NOW: sourcing sdkman-init.sh below defines its
  # own array named SDKMAN_CANDIDATES (the entire catalog), clobbering ours.
  local -a _candidates=("${SDKMAN_CANDIDATES[@]}")

  local sdkman_dir="${SDKMAN_DIR:-$HOME/.sdkman}"
  local init="$sdkman_dir/bin/sdkman-init.sh"

  # Install SDKMAN itself if it isn't present.
  if [ ! -s "$init" ]; then
    info "Installing SDKMAN"
    run bash -c 'curl -s "https://get.sdkman.io" | bash'
  fi

  local candidate
  if [ "${DRY_RUN:-false}" = "true" ]; then
    for candidate in "${_candidates[@]}"; do
      [ -n "$candidate" ] && printf '%s  [dry-run] sdk install %s%s\n' "$_C_YELLOW" "$candidate" "$_C_RESET"
    done
    return 0
  fi

  if [ ! -s "$init" ]; then
    warn "SDKMAN init not found at $init — skipping candidates."
    return 0
  fi

  # SDKMAN's init AND its `sdk` function reference unset vars (e.g. the version
  # arg $2), so neither is strict-mode safe. Relax `set -u` for the whole
  # sourcing + install block and restore it only once we're done.
  sdkman_auto_answer=false         # prompt before setting a candidate as default
  set +u
  # shellcheck disable=SC1090
  source "$init"

  for candidate in "${_candidates[@]}"; do
    # Word-split "java 17.0.19-amzn" into candidate + version (intentional).
    # shellcheck disable=SC2086
    set -- ${candidate}
    # Skip empty or whitespace-only entries: a bare `sdk install` (no name)
    # makes SDKMAN sweep its entire candidate catalog, which we never want.
    if [ "$#" -eq 0 ]; then
      warn "skipping empty SDKMAN candidate entry"
      continue
    fi
    info "sdk install $*"
    if ! sdk install "$@" </dev/null; then
      warn "sdk install $* failed"
    fi
  done

  set -u
}

_install_npm_packages() {
  [ "${#NPM_PACKAGES[@]}" -gt 0 ] || return 0
  section "Installing global npm packages"
  if ! command -v npm >/dev/null 2>&1; then
    warn "npm not found — add 'node' to BREW_PACKAGES. Skipping npm packages."
    return 0
  fi
  run npm install --global "${NPM_PACKAGES[@]}"
}

_install_pip_packages() {
  [ "${#PIP_PACKAGES[@]}" -gt 0 ] || return 0
  section "Installing pip packages"
  # Prefer pipx for isolated CLI tools when available, else pip3.
  if command -v pipx >/dev/null 2>&1; then
    local pkg
    for pkg in "${PIP_PACKAGES[@]}"; do
      [ -n "$pkg" ] && run pipx install "$pkg"
    done
  elif command -v pip3 >/dev/null 2>&1; then
    run pip3 install --user "${PIP_PACKAGES[@]}"
  else
    warn "Neither pipx nor pip3 found — add 'pipx' or 'python' to BREW_PACKAGES. Skipping."
  fi
}

_install_gem_packages() {
  [ "${#GEM_PACKAGES[@]}" -gt 0 ] || return 0
  section "Installing gem packages"
  if ! command -v gem >/dev/null 2>&1; then
    warn "gem not found — skipping gem packages."
    return 0
  fi
  run gem install "${GEM_PACKAGES[@]}"
}
