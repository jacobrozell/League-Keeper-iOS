#!/usr/bin/env bash
set -euo pipefail

DESTINATION="${1:?destination required}"

PROJECT="${CI_XCODE_PROJECT:-BudgetLeagueTracker.xcodeproj}"
SCHEME="${CI_XCODE_SCHEME:-BudgetLeagueTrackerCI}"
PACKAGES_ROOT="${CI_PACKAGES_ROOT:-.packages}"
LOG_FILE="${CI_XCODE_TEST_LOG:-xcodebuild-test.log}"
PARALLEL_TESTING="${CI_PARALLEL_TESTING:-NO}"

# Snapshot references are recorded locally; skip until __Snapshots__ are committed.
SKIP_SNAPSHOTS=(
  -skip-testing:BudgetLeagueTrackerTests/ChartsSnapshotTests
  -skip-testing:BudgetLeagueTrackerTests/ComponentSnapshotTests
  -skip-testing:BudgetLeagueTrackerTests/ScreenSnapshotTests
)

echo "::group::Running tests (without building)"
echo "Scheme: $SCHEME (parallel testing: $PARALLEL_TESTING)"

xcrun simctl ui booted content_size large 2>/dev/null || true
rm -rf TestResults.xcresult
set -o pipefail
xcodebuild test-without-building \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "$DESTINATION" \
  -parallel-testing-enabled "$PARALLEL_TESTING" \
  -derivedDataPath DerivedData \
  -clonedSourcePackagesDirPath "./${PACKAGES_ROOT}/cloned_sources" \
  -packageCachePath "$(pwd)/${PACKAGES_ROOT}/cache" \
  -resultBundlePath TestResults.xcresult \
  "${SKIP_SNAPSHOTS[@]}" \
  CODE_SIGN_IDENTITY=- \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  2>&1 | tee "$LOG_FILE" | xcbeautify --renderer github-actions
echo "::endgroup::"
