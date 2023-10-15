#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname -- "${BASH_SOURCE[0]}")"
rm -f .bazelversion bazel WORKSPACE

set -x

URL="https://github.com/facebook/buck2/releases/download/latest/buck2-x86_64-unknown-linux-musl.zst"
curl -L "$URL" | unzstd - > buck2
chmod +x buck2

./buck2 --version

rustup install nightly-2023-07-10
cargo +nightly-2023-07-10 install --root "$PWD" --git https://github.com/facebook/buck2.git buck2
# add --rev|--tag|--branch ... for specific commit

bin/buck2 --version

set +x
