#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname -- "${BASH_SOURCE[0]}")"

set -x

bazel build hello && { echo "Expected build failure"; exit 1; } || true
