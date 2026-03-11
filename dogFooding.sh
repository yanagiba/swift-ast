#!/bin/bash

make

SWIFT_AST=.build/debug/swift-ast

# Strip ANSI color codes and source ranges from dump output
normalize_dump() {
  sed 's/\x1b\[[0-9;]*m//g' | sed 's/ <range: [^>]*>//g'
}

dogfood_file() {
  local f="$1"

  # First pass: dump AST of original source
  dump1=$($SWIFT_AST -no-header -dump-ast "$f" 2>/dev/null | normalize_dump) || {
    echo "SKIP (parse error): $f"
    return 1
  }

  # Second pass: print AST, then dump the printed output
  printed=$($SWIFT_AST -no-header -print-ast "$f" 2>/dev/null) || {
    echo "SKIP (print error): $f"
    return 1
  }

  tmpfile=$(mktemp /tmp/dogfood.XXXXXX.swift)
  echo "$printed" > "$tmpfile"

  dump2=$($SWIFT_AST -no-header -dump-ast "$tmpfile" 2>/dev/null | normalize_dump) || {
    echo "FAIL (re-parse error): $f"
    rm -f "$tmpfile"
    return 2
  }

  rm -f "$tmpfile"

  if [ "$dump1" = "$dump2" ]; then
    echo "PASS: $f"
    return 0
  else
    echo "FAIL: $f"
    diff <(echo "$dump1") <(echo "$dump2") | head -20
    echo "..."
    return 2
  fi
}

# If a file is specified, test just that file
if [ $# -gt 0 ]; then
  dogfood_file "$1"
  exit $?
fi

# Otherwise, test all Swift files in the repo
allFiles=""

for f in $(find . -regex "\.\/Sources.*\.swift"); do
  allFiles="$allFiles $f"
done

for f in $(find . -regex "\.\/Tests.*\.swift"); do
  allFiles="$allFiles $f"
done

allFiles="$allFiles Package.swift"

passed=0
failed=0
skipped=0
errors=""

for f in $allFiles; do
  dogfood_file "$f"
  rc=$?
  if [ $rc -eq 0 ]; then
    passed=$((passed + 1))
  elif [ $rc -eq 1 ]; then
    skipped=$((skipped + 1))
  else
    failed=$((failed + 1))
    errors="$errors\n  $f"
  fi
done

echo ""
echo "================================"
echo "Results: $passed passed, $failed failed, $skipped skipped"
if [ $failed -gt 0 ]; then
  echo -e "Failed files:$errors"
  exit 1
fi
