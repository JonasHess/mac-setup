#!/usr/bin/env bash
# Post-process the sourced config: apply per-array removals.
#
# A config can subtract entries from any of the list variables below by
# declaring a companion <ARRAY>_REMOVE array — the counterpart to <ARRAY>+=( … ).
# This runs AFTER the whole config is sourced, so removals see the final arrays
# (base defaults + any per-person appends). Bash has no `-=` operator, so this
# companion-array convention is how you "subtract" with the same =( … ) syntax.
#
#   BREW_CASKS+=( jabra-direct )        # add
#   BREW_CASKS_REMOVE=( spotify slack ) # remove

# Arrays that support a _REMOVE companion.
_CONFIG_REMOVABLE_ARRAYS=(
  BREW_TAPS
  BREW_PACKAGES_ESSENTIAL BREW_CASKS_ESSENTIAL
  BREW_PACKAGES BREW_CASKS MAS_APPS
  NPM_PACKAGES PIP_PACKAGES GEM_PACKAGES SDKMAN_CANDIDATES
  MCP_SERVERS INTELLIJ_DEFAULT_FOR DOTFILES_FILES
)

apply_config_removals() {
  local base rem drop item
  for base in "${_CONFIG_REMOVABLE_ARRAYS[@]}"; do
    rem="${base}_REMOVE"
    # Skip unless the _REMOVE companion is declared and non-empty.
    eval "[ \"\${${rem}+x}\" = x ] && [ \"\${#${rem}[@]}\" -gt 0 ]" || continue

    # Lookup string of items to drop, surrounded by spaces: " a b c ".
    eval "set -- \"\${${rem}[@]}\""
    drop=" $* "

    # Rebuild the base array without the dropped items.
    local -a kept=()
    eval "set -- \${${base}[@]+\"\${${base}[@]}\"}"
    for item in "$@"; do
      case "$drop" in *" $item "*) continue ;; esac
      kept+=("$item")
    done
    eval "${base}=()"
    # \$item is deferred so eval re-quotes each value (preserves spaces, e.g.
    # SDKMAN "java 25.0.3-amzn").
    for item in ${kept[@]+"${kept[@]}"}; do
      eval "${base}+=( \"\$item\" )"
    done
  done
}
