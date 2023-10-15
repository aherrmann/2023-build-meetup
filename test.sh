#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname -- "${BASH_SOURCE[0]}")"

set -x

buck2 build :hello
buck2 run :hello

buck2 clean
buck2 run :hello

buck2 uquery 'rdeps(//..., owner(lib.cc))'
