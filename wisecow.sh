#!/usr/bin/env bash
set -euo pipefail

SRVPORT=4499
RSPFILE=response

rm -f "$RSPFILE"
mkfifo "$RSPFILE"

get_api() {
  IFS= read -r line
  echo "$line"
}

handleRequest() {
  get_api >/dev/null
  mod="$(fortune || echo 'No fortunes found')"
  body="<pre>$(cowsay "$mod")</pre>"

  {
    printf 'HTTP/1.1 200 OK\r\n'
    printf 'Content-Type: text/html; charset=utf-8\r\n'
    printf 'Cache-Control: no-store\r\n'
    printf 'Connection: close\r\n'
    printf '\r\n'
    printf '%s' "$body"
  } >"$RSPFILE"
}

prerequisites() {
  command -v cowsay >/dev/null 2>&1
  command -v fortune >/dev/null 2>&1
}

main() {
  if ! prerequisites; then
    echo "Install prerequisites."
    exit 1
  fi

  echo "✅ Wisdom served on port=$SRVPORT..."

  while true; do
    # -lN (listen, close after stdin EOF) keeps netcat simple in containers
    cat "$RSPFILE" | nc -lN "$SRVPORT" | handleRequest
    sleep 0.05
  done
}

main
