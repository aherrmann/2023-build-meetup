#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname -- "${BASH_SOURCE[0]}")"

set -x

buck2 build :hello && { echo "Build succeeds when it shouldn't"; }
