#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname -- "${BASH_SOURCE[0]}")"

set -x

echo "============================================================"
echo "Coarse grained"
bazel build //coarse:hello
echo >> coarse/Reykjavik.hs
bazel build -s //coarse:hello
git restore coarse/Reykjavik.hs

echo "============================================================"
echo "Fine grained"
bazel build //fine:hello
echo >> fine/Reykjavik.hs
bazel build -s //fine:hello
git restore fine/Reykjavik.hs
