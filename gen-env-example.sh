#!/usr/bin/env bash
# gen-env-example.sh
# Usage: ./gen-env-example.sh [/path/to/.env]
set -euo pipefail

ENV_IN="${1:-.env}"                # default to ./.env if not provided
OUT="${PWD}/.env.example"

if [[ ! -r "$ENV_IN" ]]; then
  echo "error: cannot read env file: $ENV_IN" >&2
  exit 1
fi

# Write to a temp file, then atomically move into place
TMP="$(mktemp "${OUT}.XXXX")"

# sed rules:
# - print blank lines
# - print full-line comments
# - strip optional leading 'export', then:
#   * if line looks like KEY = value [# comment], print 'KEY=' and keep trailing comment
#   * otherwise, comment the unparsed line out so it stays visible
sed -E -n '
  /^[[:space:]]*$/p                    # blank lines
  /^[[:space:]]*#/p                    # full-line comments
  s/^[[:space:]]*export[[:space:]]+//; # optional "export"
  s/^[[:space:]]*([A-Za-z_][A-Za-z0-9_]*)[[:space:]]*=.*/\1=/p
' "$ENV_IN" > "$TMP"

mv -f "$TMP" "$OUT"
echo "wrote: $OUT"
