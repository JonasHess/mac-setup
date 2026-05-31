#!/usr/bin/env bash
# macOS defaults: run the system-preferences script declared in the config
# (typically the `.osx` script that ships in the dotfiles repo).

run_macos_script() {
  [ -n "${MACOS_SCRIPT:-}" ] || { info "No MACOS_SCRIPT set, skipping macOS defaults"; return 0; }

  section "Applying macOS defaults"

  # MACOS_SCRIPT may include arguments (e.g. "~/.osx --no-restart"). Expand ~ and
  # split into the script path plus its arguments.
  local expanded
  expanded="${MACOS_SCRIPT/#\~/$HOME}"

  # shellcheck disable=SC2206  # word-splitting is intentional here.
  local parts=( $expanded )
  local script="${parts[0]}"

  if [ ! -f "$script" ]; then
    warn "macOS script '$script' not found — skipping (is it in your dotfiles?)"
    return 0
  fi

  run /bin/bash "${parts[@]}"
}

# Optionally empty the Dock of all pinned apps (opt-in via CLEAR_DOCK=true).
clear_dock() {
  [ "${CLEAR_DOCK:-false}" = "true" ] || return 0

  section "Clearing the Dock"
  run defaults write com.apple.dock persistent-apps -array
  # killall returns non-zero if Dock isn't running; don't let that abort the run.
  run killall Dock || true
}
