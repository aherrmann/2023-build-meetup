#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname -- "${BASH_SOURCE[0]}")"

set -x

buck2 clean
buck2 build //hello -v3
buck2 run //hello
sed 's/"$/!!"/' -i hello/Reykjavik.hs
buck2 build //hello -v3
buck2 run //hello
git restore hello/Reykjavik.hs
