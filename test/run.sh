#!/bin/bash
# Checks the download strategy and `brew jobsearch-key` with a fake server in place of the edge check (no AWS).
set -u
cd "$(dirname "$0")/.." || exit 1

URL="http://127.0.0.1:8765/jobsearch/job_search_agent-1.2.0-py3-none-any.whl"
VALID="AAAAAAAAAAAAAAAAbbbbbbbb_-_-_-_-"
WRONG="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
NO_KEY="No download key. Ask Rowena for your key, then run: brew jobsearch-key"
REFUSED="Your download key was refused. Ask Rowena for a new key."

work=$(mktemp -d)
python3 -I test/fake_server.py 8765 "$VALID" "$work/server.log" &
server=$!
trap 'kill "$server" 2>/dev/null; rm -rf "$work"' EXIT
sleep 1

passed=0
failed=0
expect() { # expect <name> <command...>: the command must succeed
  local name=$1
  shift
  if "$@"; then
    passed=$((passed + 1))
  else
    failed=$((failed + 1))
    echo "FAIL: $name"
  fi
}

make_home() { # make_home <name> [key]
  mkdir -p "$work/$1/.config/jobsearch"
  if [ $# -eq 2 ]; then
    printf 'X-Jobsearch-Key: %s\n' "$2" >"$work/$1/.config/jobsearch/download-key"
    chmod 600 "$work/$1/.config/jobsearch/download-key"
  fi
}

in_home() { # in_home <name> <brew arguments...>
  local home=$1
  shift
  HOME="$work/$home" HOMEBREW_CACHE="$work/$home/cache" HOMEBREW_NO_AUTO_UPDATE=1 brew "$@" 2>&1
}

mode() {
  python3 -c 'import os, sys; print(oct(os.stat(sys.argv[1]).st_mode & 0o777))' "$1"
}

make_home nokey
out=$(in_home nokey ruby test/fetch_check.rb "$URL")
expect "no key: the message" grep -qF "$NO_KEY" <<<"$out"
expect "no key: no request" test ! -s "$work/server.log"

make_home wrong "$WRONG"
out=$(in_home wrong ruby test/fetch_check.rb "$URL")
expect "wrong key: the message" grep -qF "$REFUSED" <<<"$out"

make_home valid "$VALID"
out=$(in_home valid ruby -v test/fetch_check.rb "$URL")
expect "valid key: the file" grep -qF "OK job_search_agent-1.2.0-py3-none-any.whl" <<<"$out"
expect "valid key: not in the output" test "$(grep -cF "$VALID" <<<"$out")" -eq 0

make_home cmd
key_file="$work/cmd/.config/jobsearch/download-key"
printf '%s\n' "$VALID" | in_home cmd ruby test/key_command_check.rb >/dev/null
expect "key command: the header line" test "$(cat "$key_file")" = "X-Jobsearch-Key: $VALID"
expect "key command: mode 600" test "$(mode "$key_file")" = "0o600"

chmod 644 "$key_file"
printf '%s\n' "$VALID" | in_home cmd ruby test/key_command_check.rb >/dev/null
expect "key command: mode 600 again" test "$(mode "$key_file")" = "0o600"

out=$(printf 'short\n' | in_home cmd ruby test/key_command_check.rb)
status=$?
expect "bad key: the message" grep -qF "That is not a download key" <<<"$out"
expect "bad key: exit 1" test "$status" -eq 1
expect "bad key: the file stays" test "$(cat "$key_file")" = "X-Jobsearch-Key: $VALID"

steps=$(grep -E '^[[:space:]]*brew (tap|trust|jobsearch-key|install)( |$)' README.md | awk '{print $1, $2}' | tr '\n' ',')
expect "README: tap, trust, key, install" test "$steps" = "brew tap,brew trust,brew jobsearch-key,brew install,"

unpinned=$(grep -hE '^[[:space:]]*(- )?uses: ' .github/workflows/*.yml | grep -cvE '@[0-9a-f]{40}([[:space:]]|$)')
expect "CI: every action pinned to a commit" test "$unpinned" -eq 0

echo "$passed passed, $failed failed"
test "$failed" -eq 0
