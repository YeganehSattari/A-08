#!/usr/bin/env bash
# analyze.sh - analyze server.log (run it from the folder that has server.log)

LOG="server.log"

echo "== total lines =="
wc -l < "$LOG"

echo "== levels =="
awk '{print $3}' "$LOG" | sort | uniq -c | sort -rn

echo "== errors with line numbers =="
grep -n ERROR "$LOG"

echo "== saving problems =="
grep -vE ' (INFO|DEBUG) ' "$LOG" > problems.txt
echo "saved to problems.txt"

echo "== top user =="
grep -o 'user=[a-z]*' "$LOG" | sort | uniq -c | sort -rn | head -1
