#!/usr/bin/env bash
set -euo pipefail

mkdir -p tmp/work tmp/cas
bazel build //src/tools/remote:worker
bazel run //src/tools/remote:worker -- \
  --listen_port=7070 \
  --work_path="$PWD/tmp/work" \
  --cas_path="$PWD/tmp/cas" \
  --sandboxing \
  --sandboxing_writable_path=/run/shm \
  --sandboxing_tmpfs_dir=/tmp \
  --sandboxing_block_network
