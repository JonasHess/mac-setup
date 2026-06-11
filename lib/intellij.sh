#!/usr/bin/env bash
# Create an "Open in IntelliJ" wrapper app that appears in Finder's "Open With"
# menu for every file, opening the selected file(s) in IntelliJ's lightweight
# LightEdit mode (the `-e` flag — a standalone editor window, no project).
#
# We can't add IntelliJ itself to "Open With" for all file types (that would mean
# editing its Info.plist, which breaks its code signature). Instead we build a
# tiny AppleScript app: it handles macOS's "open document" events — which a plain
# shell-script .app cannot — and shells out to IntelliJ for each file. The whole
# thing is created from the command line, so no Automator clicking required.

install_intellij_opener() {
  [ "${INTELLIJ_OPENER:-false}" = "true" ] || return 0

  local target_app="${INTELLIJ_APP_NAME:-IntelliJ IDEA.app}"
  local opener_name="${INTELLIJ_OPENER_NAME:-Open in IntelliJ}"
  local opener_app="$CASK_APPDIR/$opener_name.app"
  local bundle_id="${INTELLIJ_OPENER_BUNDLE_ID:-com.mac-setup.open-in-intellij}"

  section "Creating IntelliJ file opener ($opener_name)"

  # AppleScript that opens each dropped/"Open With" item in LightEdit mode.
  # `open -na` is intentional: -n lets the new launcher process start so IntelliJ
  # can forward the file to an already-running instance (a plain `open -a` would
  # just activate the running app and drop the --args).
  local src
  src="$(mktemp -t intellij-opener)"
  cat >"$src" <<APPLESCRIPT
on open theItems
    repeat with anItem in theItems
        set p to POSIX path of anItem
        do shell script "open -na " & quoted form of "$target_app" & " --args -e " & quoted form of p
    end repeat
end open
APPLESCRIPT

  # Rebuild from scratch so re-runs pick up config changes.
  run rm -rf "$opener_app"
  run osacompile -o "$opener_app" "$src"
  rm -f "$src"

  # Declare that the app can open every file type, so Finder lists it under
  # "Open With" for all files (public.item is the root of the UTI tree). The
  # osacompile droplet already ships a legacy "*" CFBundleDocumentTypes entry
  # that isn't reliable on modern macOS, so we -replace it rather than -insert.
  run plutil -replace CFBundleDocumentTypes -json \
    '[{"CFBundleTypeName":"All Files","CFBundleTypeRole":"Viewer","LSItemContentTypes":["public.item"]}]' \
    "$opener_app/Contents/Info.plist"

  # Give the app a stable bundle id so it can be named as a default handler
  # (see set_intellij_default_handlers). osacompile leaves this unset.
  run plutil -replace CFBundleIdentifier -string "$bundle_id" \
    "$opener_app/Contents/Info.plist"

  # Register with Launch Services so Finder picks it up without a relogin.
  local lsregister="/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister"
  run "$lsregister" -f "$opener_app"

  info "Created $opener_app"
  info "Right-click any file → Open With → $opener_name (opens in LightEdit)."
}

# Make the opener app the *default* (double-click) handler for the file
# extensions listed in INTELLIJ_DEFAULT_FOR. Uses `duti` to write the Launch
# Services associations.
#
# Heads up: changing a default handler makes macOS pop a confirmation dialog
# PER extension, so we warn first and pause for acknowledgement. Extensions
# without a registered file type (e.g. .edi) can't have a default set — duti
# returns error -50 — so those are reported and skipped (their right-click
# "Open With" entry still works via the all-files declaration above).
set_intellij_default_handlers() {
  [ "${INTELLIJ_OPENER:-false}" = "true" ] || return 0
  [ "${#INTELLIJ_DEFAULT_FOR[@]}" -gt 0 ] || return 0

  local bundle_id="${INTELLIJ_OPENER_BUNDLE_ID:-com.mac-setup.open-in-intellij}"
  local opener_name="${INTELLIJ_OPENER_NAME:-Open in IntelliJ}"

  section "Making '$opener_name' the default for selected file types"

  if ! command -v duti >/dev/null 2>&1; then
    warn "duti not found — add 'duti' to BREW_PACKAGES to set default handlers. Skipping."
    return 0
  fi

  warn "macOS will show one confirmation dialog per file type (${#INTELLIJ_DEFAULT_FOR[@]} total)."
  warn "For each, click the button that ACCEPTS the change — the highlighted one"
  warn "labelled \"Change\" or \"Use \"$opener_name\"\". Do NOT click \"Keep current\" / \"Cancel\"."
  # Give an interactive user a chance to bail before the dialog barrage.
  if [ -t 0 ] && [ "${DRY_RUN:-false}" != "true" ]; then
    read -r -p "    Press Enter to continue, or Ctrl-C to skip... " _
  fi

  local ext skipped=()
  for ext in "${INTELLIJ_DEFAULT_FOR[@]}"; do
    # Normalize: accept entries with or without a leading dot. duti fails for
    # extensions with no registered UTI; keep going and collect them.
    if ! run duti -s "$bundle_id" ".${ext#.}" all; then
      skipped+=("$ext")
    fi
  done

  if [ "${#skipped[@]}" -gt 0 ]; then
    warn "No registered file type for: ${skipped[*]} — left as 'Open With' only."
  fi
  info "Double-click now opens the rest in LightEdit."
}
