#!/usr/bin/env bash
# Dotfiles: clone (or update) the dotfiles repo including submodules, then link
# the files into $HOME — either with GNU Stow or with per-file symlinks.

# Clone the dotfiles repo (or update it in place), then sync submodules.
clone_dotfiles() {
  [ -n "${DOTFILES_REPO:-}" ] || { info "No DOTFILES_REPO set, skipping dotfiles"; return 0; }

  section "Setting up dotfiles repo"

  # Accept the host key automatically on first contact when requested.
  if [ "${DOTFILES_ACCEPT_HOSTKEY:-false}" = "true" ]; then
    export GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new"
  fi

  local dest version
  dest="${DOTFILES_DEST/#\~/$HOME}"
  version="${DOTFILES_VERSION:-main}"

  if [ -d "$dest/.git" ]; then
    # Repo already present — try to update, but don't abort the whole setup if
    # the remote is unreachable (offline / SSH / auth). Continue with what's
    # already checked out so the rest of the run (apps, etc.) still proceeds.
    info "Repo exists at $dest — updating to '$version'"
    if run git -C "$dest" fetch --all --prune \
       && run git -C "$dest" checkout "$version" \
       && run git -C "$dest" pull --ff-only origin "$version"; then
      :
    else
      warn "Could not update the dotfiles repo (offline, or SSH/auth issue) — continuing with the existing checkout."
    fi
  else
    run mkdir -p "$(dirname "$dest")"
    if ! run git clone --branch "$version" "$DOTFILES_REPO" "$dest"; then
      warn "Could not clone the dotfiles repo — skipping dotfiles setup. Fix access (SSH key?) and re-run."
      return 0
    fi
  fi

  # Pull in submodules (e.g. powerlevel10k, zsh plugins). Non-fatal: a single
  # broken submodule entry shouldn't abort the whole setup.
  if [ -f "$dest/.gitmodules" ] || [ "${DRY_RUN:-false}" = "true" ]; then
    info "Syncing git submodules"
    run git -C "$dest" submodule update --init --recursive \
      || warn "Some submodules failed to update — check the repo's .gitmodules"
  fi
}

# Link the dotfiles into $HOME using the configured method.
link_dotfiles() {
  [ -n "${DOTFILES_REPO:-}" ] || return 0

  case "${DOTFILES_METHOD:-symlink}" in
    stow)    _stow_dotfiles ;;
    symlink) _symlink_dotfiles ;;
    *)       error "Unknown DOTFILES_METHOD '${DOTFILES_METHOD}' (use 'stow' or 'symlink')"; return 1 ;;
  esac
}

# --- GNU Stow ---------------------------------------------------------------
# Links the whole repo into $HOME the way the repo is designed to be used,
# folding directories (e.g. ~/.config stays a real dir with per-app symlinks)
# and honoring the repo's .stow-local-ignore.
_stow_dotfiles() {
  section "Linking dotfiles with GNU Stow"

  local dest target
  dest="${DOTFILES_DEST/#\~/$HOME}"
  target="${DOTFILES_STOW_TARGET:-$HOME}"
  target="${target/#\~/$HOME}"

  if ! command -v stow >/dev/null 2>&1; then
    if [ "${DRY_RUN:-false}" = "true" ]; then
      info "stow not installed yet — it will be installed via Homebrew before this step on a real run"
    else
      warn "stow not found — add 'stow' to BREW_PACKAGES. Skipping dotfiles linking."
      return 0
    fi
  fi

  if [ ! -d "$dest" ]; then
    info "would run: stow --restow --dir $dest --target $target . (repo not present in dry run)"
    return 0
  fi

  # Pre-flight: ask stow what it would do and back up any conflicting files
  # (real files/dirs not owned by stow) so the real run doesn't fail.
  local sim
  sim="$(stow --no --verbose=2 --restow --dir "$dest" --target "$target" . 2>&1 || true)"
  local backup_dir="$HOME/.mac-setup-backups/$BACKUP_STAMP"

  local line conflict seen=" "
  while IFS= read -r line; do
    conflict=""
    case "$line" in
      # Newer stow: "* cannot stow <src> over existing target <PATH> since ..."
      *"cannot stow"*"over existing target "*" since "*)
        conflict="${line#*over existing target }"
        conflict="${conflict% since *}"
        ;;
      # Older stow: "* existing target is neither a link nor a directory: <PATH>"
      *"existing target is neither a link nor a directory: "*|*"existing target is not owned by stow: "*)
        conflict="${line##*: }"
        ;;
    esac
    [ -n "$conflict" ] || continue

    # Stow may report the same conflict more than once — handle each only once.
    case "$seen" in *" $conflict "*) continue ;; esac
    seen="$seen$conflict "

    local from="$target/$conflict"
    local to="$backup_dir/$conflict"
    # Skip if it's already gone (e.g. handled on a previous run).
    [ -e "$from" ] || [ -L "$from" ] || continue

    run mkdir -p "$(dirname "$to")"
    run mv "$from" "$to"
    info "Backed up conflicting $conflict to $backup_dir/"
  done <<EOF
$sim
EOF

  # --restow makes this idempotent (cleanly re-links on repeat runs).
  run stow --restow --verbose --dir "$dest" --target "$target" .
}

# --- Per-file symlinks ------------------------------------------------------
# Links each DOTFILES_FILES entry from the repo into $HOME, backing up anything
# already there. Used when DOTFILES_METHOD=symlink.
_symlink_dotfiles() {
  [ "${#DOTFILES_FILES[@]}" -gt 0 ] || { info "No DOTFILES_FILES listed, nothing to link"; return 0; }

  section "Linking dotfiles into \$HOME"

  local dest backup_dir
  dest="${DOTFILES_DEST/#\~/$HOME}"
  backup_dir="$HOME/.mac-setup-backups/$BACKUP_STAMP"

  local file src target
  for file in "${DOTFILES_FILES[@]}"; do
    [ -n "$file" ] || continue
    src="$dest/$file"
    target="$HOME/$file"

    if [ ! -e "$src" ]; then
      if [ "${DRY_RUN:-false}" = "true" ]; then
        # The clone was only simulated, so sources aren't on disk yet.
        info "would link $file -> $target (after clone)"
      else
        warn "Source $src does not exist in dotfiles repo — skipping"
      fi
      continue
    fi

    # Already linked to the right place? Nothing to do.
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$src" ]; then
      info "$file already linked"
      continue
    fi

    # Back up anything currently at the target (real file, dir, or wrong link).
    if [ -e "$target" ] || [ -L "$target" ]; then
      run mkdir -p "$backup_dir"
      run mv "$target" "$backup_dir/"
      info "Backed up existing $file to $backup_dir/"
    fi

    run ln -s "$src" "$target"
  done
}
