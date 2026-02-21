#!/usr/bin/env sh
set -eu

OUT_FILE="$(mktemp "${TMPDIR:-/tmp}/forge-check.XXXXXX")"
cleanup() {
  rm -f "$OUT_FILE"
}
trap cleanup EXIT INT TERM

swift test >"$OUT_FILE" 2>&1 || TEST_STATUS=$?
TEST_STATUS="${TEST_STATUS:-0}"
cat "$OUT_FILE"

if [ "$TEST_STATUS" -eq 0 ]; then
  exit 0
fi

if grep -Eq "PCH was compiled with module cache path|missing required module 'SwiftShims'" "$OUT_FILE"; then
  echo "Detected stale Swift module cache in .build; cleaning and retrying once..." >&2
  rm -rf .build
  swift test
  exit $?
fi

exit "$TEST_STATUS"
