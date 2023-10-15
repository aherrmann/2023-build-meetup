#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname -- "${BASH_SOURCE[0]}")"

set -x

# Build the Bazel remote worker.
(
  cd ../00-bazel-worker
  bazel build //src/tools/remote:worker
)

# Run the Bazel remote worker in the background.
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT
(
  cd ../00-bazel-worker
  mkdir -p tmp/work tmp/cas
  bazel run //src/tools/remote:worker -- \
    --listen_port=7070 \
    --work_path="$PWD/tmp/work" \
    --cas_path="$PWD/tmp/cas" \
    --sandboxing \
    --sandboxing_writable_path=/run/shm \
    --sandboxing_tmpfs_dir=/tmp \
    --sandboxing_block_network
) &

sleep 2

buck2 clean
buck2 build :hello && { echo "Expected build failure"; exit 1; } || true
