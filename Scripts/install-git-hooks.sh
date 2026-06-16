#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
git config core.hooksPath .githooks
echo "Installed git hooks from ${REPO_ROOT}/.githooks"
