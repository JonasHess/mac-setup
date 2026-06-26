#!/usr/bin/env bash
# Install + register Claude Code MCP (Model Context Protocol) servers.
#
# The config declares which servers to install in MCP_SERVERS, and a block of
# MCP_<NAME>_* variables per server. Re-running is safe — existing checkouts
# are pulled, existing registrations are replaced.
#
# Contract per server (NAME → upper-case for variable lookup, e.g. "redmine"
# reads MCP_REDMINE_TYPE):
#
#   MCP_<N>_TYPE       (required)  uv-git | npx | command
#   MCP_<N>_REQUIRES   (optional)  array of shell env vars that must be set
#                                  before install (typically secrets sourced
#                                  from your dotfiles' secrets file). Each
#                                  entry is also auto-forwarded to the MCP
#                                  server's environment:
#                                    "FOO"             → require shell var FOO,
#                                                       forward as FOO=$FOO
#                                    "MCP_NAME=SHELL"  → require shell var
#                                                       SHELL, forward as
#                                                       MCP_NAME=$SHELL (use
#                                                       this when the secret
#                                                       lives under a different
#                                                       name in your shell)
#   MCP_<N>_ENV        (optional)  array of "KEY=VALUE" non-secret env vars,
#                                  passed to `claude mcp add -e`. Takes
#                                  precedence over REQUIRES auto-forwarding
#                                  if both define the same KEY.
#
# Per-type variables:
#
#   uv-git — clone a git repo, pin Python, `uv sync`, `uv tool install .`:
#     MCP_<N>_REPO     git URL
#     MCP_<N>_DEST     local checkout path
#     MCP_<N>_BIN      absolute path of the installed binary (registered as cmd)
#     MCP_<N>_PYTHON   (optional) Python version pin, e.g. "3.12"
#     MCP_<N>_ARGS     (optional) array of subprocess args
#
#   npx — register an npx invocation (no pre-install):
#     MCP_<N>_PACKAGE  npm package, e.g. "@modelcontextprotocol/server-github"
#     MCP_<N>_NPX_ARGS (optional) array of extra flags (e.g. ("-y"))
#
#   command — register a binary that is already on PATH:
#     MCP_<N>_COMMAND  command to run (absolute path recommended)
#     MCP_<N>_ARGS     (optional) array of subprocess args

install_mcp_servers() {
  [ "${#MCP_SERVERS[@]}" -gt 0 ] || return 0
  section "Installing Claude Code MCP servers"

  # Let an interactive user opt out of the whole MCP step without aborting the
  # run — installing servers clones repos, runs uv/npx, and prompts for any
  # missing secrets, which a user may want to skip. Answering "n" skips *this*
  # step only; "y" (the default) proceeds. Mirrors set_intellij_default_handlers.
  if [ -t 0 ] && [ "${DRY_RUN:-false}" != "true" ]; then
    info "About to install ${#MCP_SERVERS[@]} MCP server(s): ${MCP_SERVERS[*]}"
    local _ans
    read -r -p "    Install MCP servers now? [Y/n] " _ans
    case "${_ans:-y}" in
      [Nn]*)
        warn "Skipping MCP server installation."
        return 0
        ;;
    esac
  fi

  if ! command -v claude >/dev/null 2>&1; then
    warn "claude CLI not on PATH — install Claude Code first. Skipping MCP servers."
    return 0
  fi

  local name
  for name in "${MCP_SERVERS[@]}"; do
    [ -n "$name" ] || continue
    _install_one_mcp "$name"
  done
}

# --- internals -------------------------------------------------------------

# Translate a server name (e.g. "github-issues") to the variable-suffix form
# ("GITHUB_ISSUES") used for MCP_<UPPER>_* lookup.
_mcp_upper() { printf '%s' "$1" | tr '[:lower:]-' '[:upper:]_'; }

# Read a scalar MCP variable; empty if unset.
_mcp_var() {
  local u="$1" s="$2"
  local v="MCP_${u}_${s}"
  printf '%s' "${!v:-}"
}

# Print each element of MCP_<u>_<suffix> (an array) on its own line. Nothing
# if the variable is unset — safe under `set -u`.
_mcp_array() {
  local u="$1" s="$2"
  local var="MCP_${u}_${s}"
  if eval "[ \${${var}+x} ]"; then
    eval "printf '%s\n' \"\${${var}[@]}\""
  fi
}

_mcp_secrets_file() {
  printf '%s' "${SECRETS_FILE:-${DOTFILES_DEST:-$HOME}/secrets.zsh}"
}

# Split a REQUIRES entry into "mcp_env_name shell_var_name". A plain "FOO"
# maps to "FOO FOO" (auto-forward under the same name); "MCP=SHELL" maps to
# "MCP SHELL" (rename: require shell var SHELL, forward as MCP=$SHELL).
_mcp_split_required() {
  local entry="$1"
  if [[ "$entry" == *=* ]]; then
    printf '%s %s' "${entry%%=*}" "${entry#*=}"
  else
    printf '%s %s' "$entry" "$entry"
  fi
}

# Resolve a missing required var. Returns 0 if the var is now exported in this
# shell, non-zero if the caller should skip this MCP.
_mcp_prompt_secret() {
  local mcp_name="$1" var="$2"
  local file; file="$(_mcp_secrets_file)"

  # Already in the secrets file but not exported in this shell — the user just
  # needs a new shell. Don't double-write it.
  if [ -f "$file" ] && grep -qE "^[[:space:]]*export[[:space:]]+${var}=" "$file"; then
    warn "MCP '$mcp_name': '$var' is in $file but not exported in this shell. Open a new shell and re-run. Skipping."
    return 1
  fi

  # No TTY (CI, piped input) or dry run — don't try to read input.
  if [ "${DRY_RUN:-false}" = "true" ] || [ ! -r /dev/tty ]; then
    warn "MCP '$mcp_name': '$var' is not exported and we cannot prompt (dry-run / no tty). Add it to $file and re-run. Skipping."
    return 1
  fi

  # Prompt from /dev/tty so the prompt survives stdin redirection.
  local value=""
  printf '%s    Enter %s for MCP %s (input hidden, empty to skip): %s' \
    "$_C_GREEN" "$var" "$mcp_name" "$_C_RESET" > /dev/tty
  IFS= read -rs value < /dev/tty
  printf '\n' > /dev/tty
  if [ -z "$value" ]; then
    warn "MCP '$mcp_name': no value entered for '$var' — skipping."
    return 1
  fi

  # Create the secrets file with restrictive perms on first use; never widen
  # permissions if the user already locked it down differently.
  if [ ! -f "$file" ]; then
    run mkdir -p "$(dirname "$file")"
    run touch "$file"
    run chmod 600 "$file"
  fi

  # Append with %q quoting so any unusual characters in the value round-trip
  # cleanly when the file is sourced. Don't go through `run` — that echoes the
  # command (including the secret) to stdout.
  printf 'export %s=%q\n' "$var" "$value" >> "$file"
  info "MCP '$mcp_name': saved $var to $file"

  # Export for the rest of this run.
  export "$var=$value"
}

_install_one_mcp() {
  local name="$1"
  local u; u="$(_mcp_upper "$name")"
  local type; type="$(_mcp_var "$u" TYPE)"
  if [ -z "$type" ]; then
    warn "MCP '$name': MCP_${u}_TYPE not set — skipping."
    return 0
  fi

  # Required env vars (typically secrets) must be exported in this shell. If
  # one is missing, try to prompt the user and persist the value to the secrets
  # file (default: $DOTFILES_DEST/secrets.zsh). Fall back to skip on dry-run,
  # when there is no TTY, or when the value is already in the file but just
  # hasn't been sourced into this shell. Each REQUIRES entry is also forwarded
  # to the MCP server's env at register time (see _mcp_register).
  local req shell_var
  while IFS= read -r req; do
    [ -n "$req" ] || continue
    # shellcheck disable=SC2034
    read -r _ shell_var <<<"$(_mcp_split_required "$req")"
    if [ -z "${!shell_var:-}" ]; then
      _mcp_prompt_secret "$name" "$shell_var" || return 0
    fi
  done < <(_mcp_array "$u" REQUIRES)

  case "$type" in
    uv-git)  _mcp_install_uv_git  "$name" "$u" ;;
    npx)     _mcp_install_npx     "$name" "$u" ;;
    command) _mcp_install_command "$name" "$u" ;;
    *)       warn "MCP '$name': unknown type '$type' — skipping."; return 0 ;;
  esac
}

# Run a uv command inside a checkout. On a real run the repo was just cloned,
# so cd succeeds. Under --dry-run the clone was only echoed and $dest may not
# exist — skip the cd in that case and just echo the command via `run`, so the
# dry-run previews the full sequence instead of aborting on a failed cd.
_mcp_uv_in() {
  local dest="$1"; shift
  if [ -d "$dest" ]; then
    ( cd "$dest" && run "$@" )
  else
    run "$@"
  fi
}

_mcp_install_uv_git() {
  local name="$1" u="$2"
  local repo dest bin python
  repo="$(_mcp_var "$u" REPO)"
  dest="$(_mcp_var "$u" DEST)"
  bin="$(_mcp_var "$u" BIN)"
  python="$(_mcp_var "$u" PYTHON)"

  if [ -z "$repo" ] || [ -z "$dest" ] || [ -z "$bin" ]; then
    warn "MCP '$name': uv-git needs MCP_${u}_REPO, _DEST, _BIN — skipping."
    return 0
  fi
  if ! command -v uv >/dev/null 2>&1; then
    warn "MCP '$name': 'uv' not on PATH — add it to BREW_PACKAGES. Skipping."
    return 0
  fi

  info "MCP '$name': syncing $repo at $dest"
  if [ -d "$dest/.git" ]; then
    run git -C "$dest" pull --ff-only
  else
    run mkdir -p "$(dirname "$dest")"
    run git clone "$repo" "$dest"
  fi

  if [ -n "$python" ]; then
    _mcp_uv_in "$dest" uv python pin "$python"
  fi
  _mcp_uv_in "$dest" uv sync

  # --force makes uv tool install idempotent (overwrite an existing tool env).
  if [ -n "$python" ]; then
    _mcp_uv_in "$dest" uv tool install --force --python "$python" .
  else
    _mcp_uv_in "$dest" uv tool install --force .
  fi

  local -a extra=()
  local line
  while IFS= read -r line; do
    [ -n "$line" ] && extra+=("$line")
  done < <(_mcp_array "$u" ARGS)
  _mcp_register "$name" "$u" "$bin" "${extra[@]}"
}

_mcp_install_npx() {
  local name="$1" u="$2"
  local pkg; pkg="$(_mcp_var "$u" PACKAGE)"
  if [ -z "$pkg" ]; then
    warn "MCP '$name': npx needs MCP_${u}_PACKAGE — skipping."
    return 0
  fi
  if ! command -v npx >/dev/null 2>&1; then
    warn "MCP '$name': 'npx' not on PATH — add 'node' to BREW_PACKAGES. Skipping."
    return 0
  fi
  local -a extra=()
  local line
  while IFS= read -r line; do
    [ -n "$line" ] && extra+=("$line")
  done < <(_mcp_array "$u" NPX_ARGS)
  _mcp_register "$name" "$u" "npx" "${extra[@]}" "$pkg"
}

_mcp_install_command() {
  local name="$1" u="$2"
  local cmd; cmd="$(_mcp_var "$u" COMMAND)"
  if [ -z "$cmd" ]; then
    warn "MCP '$name': 'command' type needs MCP_${u}_COMMAND — skipping."
    return 0
  fi
  local -a extra=()
  local line
  while IFS= read -r line; do
    [ -n "$line" ] && extra+=("$line")
  done < <(_mcp_array "$u" ARGS)
  _mcp_register "$name" "$u" "$cmd" "${extra[@]}"
}

# Replace any existing registration for $name at user scope with the given
# command + args. Trailing positional args are the child command + its argv.
_mcp_register() {
  local name="$1" u="$2"; shift 2

  local -a env_flags=()
  local line mcp_name shell_var
  # REQUIRES first: auto-forward each required shell var as MCP env. ENV
  # comes next so a literal "KEY=value" in ENV overrides any REQUIRES entry
  # with the same KEY (claude mcp add -e takes last-wins semantics).
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    read -r mcp_name shell_var <<<"$(_mcp_split_required "$line")"
    env_flags+=(-e "$mcp_name=${!shell_var:-}")
  done < <(_mcp_array "$u" REQUIRES)
  while IFS= read -r line; do
    [ -n "$line" ] && env_flags+=(-e "$line")
  done < <(_mcp_array "$u" ENV)

  if [ "${DRY_RUN:-false}" = "true" ]; then
    printf '%s  [dry-run] claude mcp remove %s --scope user%s\n' \
      "$_C_YELLOW" "$name" "$_C_RESET"
  else
    # `mcp remove` errors when the name is not registered; that's fine here.
    claude mcp remove "$name" --scope user >/dev/null 2>&1 || true
  fi
  run claude mcp add "$name" --scope user "${env_flags[@]}" -- "$@"
}
