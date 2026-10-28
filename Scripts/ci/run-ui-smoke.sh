#!/usr/bin/env bash
set -euo pipefail

DESTINATION="${1:?destination required}"

PROJECT="${CI_XCODE_PROJECT:-League Keeper.xcodeproj}"
PACKAGES_ROOT="${CI_PACKAGES_ROOT:-.packages}"
LOG_FILE="${CI_XCODE_UI_LOG:-xcodebuild-ui-smoke.log}"

# Launch → create tournament → score one round, plus seeded tournament detail checks.
SMOKE_TESTS=(
  -only-testing:BudgetLeagueTrackerUITests/SmokeFlowTests
  -only-testing:BudgetLeagueTrackerUITests/TournamentsScreenTests/testTournamentDetailStandingsSection
  -only-testing:BudgetLeagueTrackerUITests/WeeklyRoundFlowTests/testWeekCompleteShowsShareButton
)

echo "::group::Running UI smoke tests"
rm -rf UISmokeResults.xcresult
set -o pipefail
xcodebuild test \
  -project "$PROJECT" \
  -scheme BudgetLeagueTrackerUI \
  -destination "$DESTINATION" \
  -parallel-testing-enabled NO \
  -derivedDataPath DerivedData \
  -clonedSourcePackagesDirPath "./${PACKAGES_ROOT}/cloned_sources" \
  -packageCachePath "$(pwd)/${PACKAGES_ROOT}/cache" \
  -resultBundlePath UISmokeResults.xcresult \
  "${SMOKE_TESTS[@]}" \
  CODE_SIGN_IDENTITY=- \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  2>&1 | tee "$LOG_FILE" | xcbeautify --renderer github-actions
echo "::endgroup::"
