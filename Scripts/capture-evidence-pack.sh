#!/usr/bin/env bash
# Capture layout, marketing, AXXXL, and a11y audit evidence on iOS simulators.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HELPERS="$ROOT/Scripts/capture_sim_helpers.py"
BUNDLE_ID="com.jacobrozell.leaguekeeper"
DATE_TAG="${DATE_TAG:-2026-06-19}"

IPHONE_UDID="${IPHONE_UDID:-68292785-6474-4C43-8CA0-AF209F379D3D}"
IPAD_UDID="${IPAD_UDID:-96A80753-FCA0-402F-8CEA-3D06228190E6}"

DERIVED_DATA="${DERIVED_DATA:-/tmp/LeagueKeeperEvidenceDerivedData}"
APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/BudgetLeagueTracker.app"

LAYOUT_DIR="$ROOT/accessibility/evidence/layout/screenshots/$DATE_TAG"
AXXXL_DIR="$ROOT/accessibility/wcag-2.1-aa/evidence/dynamic-type/$DATE_TAG"
AUDIT_DIR="$ROOT/accessibility/wcag-2.1-aa/evidence/voiceover/$DATE_TAG"
MARKETING_IPHONE="$ROOT/marketing-screenshots/raw/$DATE_TAG"
MARKETING_IPAD="$ROOT/marketing-screenshots/ipad/raw/$DATE_TAG"

DELAY="${LAUNCH_DELAY:-4}"

log() { printf '==> %s\n' "$*"; }

build_app() {
  if [[ "${SKIP_BUILD:-0}" == "1" ]]; then
    log "Skipping build (SKIP_BUILD=1)"
    return 0
  fi
  log "Building app"
  xcodebuild build \
    -project "$ROOT/League Keeper.xcodeproj" \
    -scheme BudgetLeagueTracker \
    -destination "platform=iOS Simulator,id=$IPHONE_UDID" \
    -derivedDataPath "$DERIVED_DATA" \
    CODE_SIGNING_ALLOWED=NO >/dev/null
}

boot_sims() {
  xcrun simctl boot "$IPHONE_UDID" 2>/dev/null || true
  xcrun simctl boot "$IPAD_UDID" 2>/dev/null || true
  open -a Simulator --args -CurrentDeviceUDID "$IPHONE_UDID" 2>/dev/null || open -a Simulator
}

launch_app() {
  local udid="$1"
  shift
  xcrun simctl terminate "$udid" "$BUNDLE_ID" 2>/dev/null || true
  xcrun simctl install "$udid" "$APP_PATH"
  # shellcheck disable=SC2068
  xcrun simctl launch --terminate-running-process "$udid" "$BUNDLE_ID" $@
  sleep "$DELAY"
}

shot() {
  local udid="$1" path="$2"
  python3 "$HELPERS" screenshot "$udid" "$path"
}

audit() {
  local udid="$1" path="$2"
  python3 "$HELPERS" audit "$udid" "$path"
}

orient() {
  python3 "$HELPERS" orient "$1"
}

tap_label() {
  local udid="$1" label="$2"
  shift 2
  if [[ "${1:-}" == "--contains" ]]; then
    python3 "$HELPERS" tap-label "$udid" "$label" --contains || true
  else
    python3 "$HELPERS" tap-label "$udid" "$label" || true
  fi
  sleep 1
}

tap_uid() {
  python3 "$HELPERS" tap-uid "$1" "$2" || true
  sleep 1
}

copy_marketing() {
  local src="$1" dest_dir="$2" name="$3"
  [[ -f "$src" ]] || return 0
  mkdir -p "$dest_dir"
  cp "$src" "$dest_dir/$name"
}

capture_marketing_shot() {
  local udid="$1" slug="$2" theme="$3" a11y="$4" orient_tag="$5" marketing_dir="$6"
  local snapshot="$7" filename="$8"
  local prefix="$slug-${theme}"
  [[ "$a11y" == "1" ]] && prefix="${prefix}-axxxl"

  local args=(--uitesting UI-Testing-Marketing-Seed "$snapshot")
  [[ "$theme" == "dark" ]] && args+=(UI-Testing-DarkTheme)
  [[ "$a11y" == "1" ]] && args+=(UI-Testing-Accessibility)

  launch_app "$udid" "${args[@]}"
  shot "$udid" "$LAYOUT_DIR/${prefix}-${filename}-${orient_tag}.png"
  copy_marketing "$LAYOUT_DIR/${prefix}-${filename}-${orient_tag}.png" "$marketing_dir" "${prefix}-${filename}-${orient_tag}.png"
}

capture_tournament_flow() {
  local udid="$1" slug="$2" theme="$3" a11y="$4" orient_tag="$5" marketing_dir="$6"
  local prefix="$slug-${theme}"
  [[ "$a11y" == "1" ]] && prefix="${prefix}-axxxl"

  capture_marketing_shot "$udid" "$slug" "$theme" "$a11y" "$orient_tag" "$marketing_dir" \
    "UI-Testing-Snapshot-TournamentsList" "01-tournaments"

  capture_marketing_shot "$udid" "$slug" "$theme" "$a11y" "$orient_tag" "$marketing_dir" \
    "UI-Testing-Snapshot-DetailRound" "02-round"
  audit "$udid" "$AUDIT_DIR/${prefix}-02-round-${orient_tag}.json"

  capture_marketing_shot "$udid" "$slug" "$theme" "$a11y" "$orient_tag" "$marketing_dir" \
    "UI-Testing-Snapshot-DetailStandings" "03-standings"

  capture_marketing_shot "$udid" "$slug" "$theme" "$a11y" "$orient_tag" "$marketing_dir" \
    "UI-Testing-Snapshot-TabStats" "04-stats"
  audit "$udid" "$AUDIT_DIR/${prefix}-04-stats-${orient_tag}.json"

  capture_marketing_shot "$udid" "$slug" "$theme" "$a11y" "$orient_tag" "$marketing_dir" \
    "UI-Testing-Snapshot-TabAchievements" "05-achievements"

  capture_marketing_shot "$udid" "$slug" "$theme" "$a11y" "$orient_tag" "$marketing_dir" \
    "UI-Testing-Snapshot-TabSettings" "06-settings"
}

capture_attendance() {
  local udid="$1" slug="$2" theme="$3" a11y="$4" orient_tag="$5"
  local prefix="$slug-${theme}"
  [[ "$a11y" == "1" ]] && prefix="${prefix}-axxxl"
  local args=(--uitesting UI-Testing-Marketing-Seed UI-Testing-Snapshot-DetailAttendance)
  [[ "$theme" == "dark" ]] && args+=(UI-Testing-DarkTheme)
  [[ "$a11y" == "1" ]] && args+=(UI-Testing-Accessibility)
  launch_app "$udid" "${args[@]}"
  shot "$udid" "$LAYOUT_DIR/${prefix}-attendance-${orient_tag}.png"
  audit "$udid" "$AUDIT_DIR/${prefix}-attendance-${orient_tag}.json"
}

capture_onboarding() {
  local udid="$1" slug="$2" theme="$3" orient_tag="$4" marketing_dir="$5"
  local prefix="$slug-${theme}"
  xcrun simctl uninstall "$udid" "$BUNDLE_ID" 2>/dev/null || true
  xcrun simctl install "$udid" "$APP_PATH"
  local args=(UI-Testing-Onboarding)
  [[ "$theme" == "dark" ]] && args+=(UI-Testing-DarkTheme)
  xcrun simctl launch --terminate-running-process "$udid" "$BUNDLE_ID" "${args[@]}"
  sleep "$DELAY"
  shot "$udid" "$LAYOUT_DIR/${prefix}-07-onboarding-${orient_tag}.png"
  copy_marketing "$LAYOUT_DIR/${prefix}-07-onboarding-${orient_tag}.png" "$marketing_dir" "${prefix}-07-onboarding-${orient_tag}.png"
  audit "$udid" "$AUDIT_DIR/${prefix}-07-onboarding-${orient_tag}.json"
}

capture_device() {
  local udid="$1" slug="$2"
  local marketing_dir="$MARKETING_IPHONE"
  [[ "$slug" == ipad* ]] && marketing_dir="$MARKETING_IPAD"
  mkdir -p "$LAYOUT_DIR" "$AXXXL_DIR" "$AUDIT_DIR" "$marketing_dir"

  open -a Simulator --args -CurrentDeviceUDID "$udid" 2>/dev/null || true
  sleep 1
  orient portrait
  sleep 1

  log "$slug light portrait"
  capture_tournament_flow "$udid" "$slug" light 0 portrait "$marketing_dir"
  capture_attendance "$udid" "$slug" light 0 portrait
  capture_onboarding "$udid" "$slug" light portrait "$marketing_dir"

  log "$slug light landscape"
  orient landscape
  sleep 1
  capture_attendance "$udid" "$slug" light 0 landscape
  capture_tournament_flow "$udid" "$slug" light 0 landscape "$marketing_dir"

  log "$slug dark portrait"
  orient portrait
  sleep 1
  capture_tournament_flow "$udid" "$slug" dark 0 portrait "$marketing_dir"

  log "$slug AXXXL portrait"
  capture_attendance "$udid" "$slug" light 1 portrait
  capture_tournament_flow "$udid" "$slug" light 1 portrait "$marketing_dir"
  copy_marketing "$LAYOUT_DIR/${slug}-light-axxxl-02-round-portrait.png" "$AXXXL_DIR" "${slug}-tournament-round-portrait.png"
  copy_marketing "$LAYOUT_DIR/${slug}-light-axxxl-04-stats-portrait.png" "$AXXXL_DIR" "${slug}-stats-portrait.png"
  copy_marketing "$LAYOUT_DIR/${slug}-light-axxxl-attendance-portrait.png" "$AXXXL_DIR" "${slug}-attendance-portrait.png"

  log "$slug AXXXL landscape"
  orient landscape
  sleep 1
  capture_attendance "$udid" "$slug" light 1 landscape
  copy_marketing "$LAYOUT_DIR/${slug}-light-axxxl-attendance-landscape.png" "$AXXXL_DIR" "${slug}-attendance-landscape.png"
  capture_tournament_flow "$udid" "$slug" light 1 landscape "$marketing_dir"
  copy_marketing "$LAYOUT_DIR/${slug}-light-axxxl-02-round-landscape.png" "$AXXXL_DIR" "${slug}-tournament-round-landscape.png"

  orient portrait
}

mkdir -p "$MARKETING_IPHONE" "$MARKETING_IPAD"
build_app
boot_sims

case "${RUN_MODE:-full}" in
  finish)
    open -a Simulator --args -CurrentDeviceUDID "$IPHONE_UDID" 2>/dev/null || true
    sleep 1
    orient landscape
    sleep 1
    log "iphone17 AXXXL landscape"
    capture_attendance "$IPHONE_UDID" "iphone17" light 1 landscape
    copy_marketing "$LAYOUT_DIR/iphone17-light-axxxl-attendance-landscape.png" "$AXXXL_DIR" "iphone17-attendance-landscape.png"
    capture_tournament_flow "$IPHONE_UDID" "iphone17" light 1 landscape "$MARKETING_IPHONE"
    copy_marketing "$LAYOUT_DIR/iphone17-light-axxxl-02-round-landscape.png" "$AXXXL_DIR" "iphone17-tournament-round-landscape.png"
    orient portrait
    capture_device "$IPAD_UDID" "ipad13"
    ;;
  full)
    capture_device "$IPHONE_UDID" "iphone17"
    capture_device "$IPAD_UDID" "ipad13"
    ;;
esac

log "Done. Outputs:"
log "  Layout:    $LAYOUT_DIR"
log "  AXXXL:     $AXXXL_DIR"
log "  Audits:    $AUDIT_DIR"
log "  Marketing: $MARKETING_IPHONE + $MARKETING_IPAD"
