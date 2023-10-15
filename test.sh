#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname -- "${BASH_SOURCE[0]}")"

set -x

bazel build hello
bazel run hello

bazel clean
bazel run hello

bazel query 'rdeps(//..., lib.cc)'
