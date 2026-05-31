#!/usr/bin/env bash
# Optional language package managers. Each runs only if its array is non-empty
# and the corresponding tool is available. Empty by default.

install_language_packages() {
  _install_npm_packages
  _install_pip_packages
  _install_gem_packages
}

_install_npm_packages() {
  [ "${#NPM_PACKAGES[@]:-0}" -gt 0 ] || return 0
  section "Installing global npm packages"
  if ! command -v npm >/dev/null 2>&1; then
    warn "npm not found — add 'node' to BREW_PACKAGES. Skipping npm packages."
    return 0
  fi
  run npm install --global "${NPM_PACKAGES[@]}"
}

_install_pip_packages() {
  [ "${#PIP_PACKAGES[@]:-0}" -gt 0 ] || return 0
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
  [ "${#GEM_PACKAGES[@]:-0}" -gt 0 ] || return 0
  section "Installing gem packages"
  if ! command -v gem >/dev/null 2>&1; then
    warn "gem not found — skipping gem packages."
    return 0
  fi
  run gem install "${GEM_PACKAGES[@]}"
}
