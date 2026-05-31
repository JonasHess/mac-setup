#!/usr/bin/env bash
# Logging helpers and a DRY_RUN-aware command runner.
# Sourced by setup.sh; relies on DRY_RUN being set (true/false) by the caller.

# Colors (fall back to empty strings if stdout is not a tty).
if [ -t 1 ]; then
  _C_RESET="$(printf '\033[0m')"
  _C_BOLD="$(printf '\033[1m')"
  _C_BLUE="$(printf '\033[34m')"
  _C_GREEN="$(printf '\033[32m')"
  _C_YELLOW="$(printf '\033[33m')"
  _C_RED="$(printf '\033[31m')"
else
  _C_RESET="" _C_BOLD="" _C_BLUE="" _C_GREEN="" _C_YELLOW="" _C_RED=""
fi

section() { printf '\n%s%s==> %s%s\n' "$_C_BOLD" "$_C_BLUE" "$*" "$_C_RESET"; }
info()    { printf '%s    %s%s\n' "$_C_GREEN" "$*" "$_C_RESET"; }
warn()    { printf '%s[warn] %s%s\n' "$_C_YELLOW" "$*" "$_C_RESET" >&2; }
error()   { printf '%s[error] %s%s\n' "$_C_RED" "$*" "$_C_RESET" >&2; }

# run CMD...  — echo the command, then execute it (or just print under --dry-run).
run() {
  if [ "${DRY_RUN:-false}" = "true" ]; then
    printf '%s  [dry-run] %s%s\n' "$_C_YELLOW" "$*" "$_C_RESET"
    return 0
  fi
  printf '%s  + %s%s\n' "$_C_BOLD" "$*" "$_C_RESET"
  "$@"
}
