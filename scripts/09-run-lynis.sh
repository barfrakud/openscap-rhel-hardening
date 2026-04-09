#!/usr/bin/env bash
# 09-run-lynis.sh
# Install and run Lynis audit for comparison with OpenSCAP results
set -euo pipefail

REPORT_DIR="/root/openscap-reports"
DATE=$(date +%Y-%m-%d)

mkdir -p "${REPORT_DIR}"

echo "=== Checking Lynis installation ==="

if ! command -v lynis &>/dev/null; then
  echo "Lynis not found. Installing..."
  dnf install -y epel-release 2>/dev/null || true
  dnf install -y lynis
fi

echo "Lynis version: $(lynis --version 2>/dev/null || lynis show version)"
echo ""

echo "=== Running Lynis system audit ==="
echo "Date: ${DATE}"
echo ""

# Run full audit (non-interactive, no colors for clean log)
lynis audit system \
  --no-colors \
  --logfile "${REPORT_DIR}/lynis-log-${DATE}.txt" \
  --report-file "${REPORT_DIR}/lynis-data-${DATE}.dat" \
  2>&1 | tee "${REPORT_DIR}/lynis-output-${DATE}.txt"

echo ""
echo "=== Lynis audit complete ==="
echo ""

# Extract key metrics
echo "--- KEY METRICS ---"
grep "Hardening index" "${REPORT_DIR}/lynis-output-${DATE}.txt" || echo "  (check report manually)"
echo ""

echo "Warnings:"
grep -c "warning\[\]" "${REPORT_DIR}/lynis-data-${DATE}.dat" 2>/dev/null || echo "  0"

echo "Suggestions:"
grep -c "suggestion\[\]" "${REPORT_DIR}/lynis-data-${DATE}.dat" 2>/dev/null || echo "  0"

echo ""
echo "=== Reports saved ==="
ls -lh "${REPORT_DIR}"/lynis-*-${DATE}.*
