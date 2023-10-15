#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname -- "${BASH_SOURCE[0]}")"
rm -f .bazelversion bazel WORKSPACE

set -x

URL="https://github.com/bazelbuild/bazelisk/releases/download/v1.18.0/bazelisk-linux-amd64"
curl -L "$URL" -o bazel
chmod +x bazel

./bazel version
USE_BAZEL_VERSION=5.0.0 ./bazel version
USE_BAZEL_VERSION=last_green ./bazel version

echo '6.0.0' > .bazelversion
touch WORKSPACE
./bazel version

set +x
