#!/usr/bin/env bash
# 06-compare-results.sh
# Compare baseline and post-hardening scan results
set -euo pipefail

REPORT_DIR="/root/openscap-reports"

# Find most recent baseline and post results
BASELINE=$(ls -t "${REPORT_DIR}"/baseline-results-*.xml 2>/dev/null | head -1)
POST=$(ls -t "${REPORT_DIR}"/post-results-*.xml 2>/dev/null | head -1)

if [[ -z "${BASELINE}" ]]; then
  echo "ERROR: No baseline results found. Run 03-run-baseline-scan.sh first."
  exit 1
fi

if [[ -z "${POST}" ]]; then
  echo "ERROR: No post-hardening results found. Run 05-run-post-scan.sh first."
  exit 1
fi

echo "=== Comparing scan results ==="
echo "Baseline: ${BASELINE}"
echo "Post:     ${POST}"
echo ""

# Count results from each scan
echo "--- BASELINE SCAN ---"
echo -n "  Pass:           "; grep -c 'result="pass"' "${BASELINE}" || echo "0"
echo -n "  Fail:           "; grep -c 'result="fail"' "${BASELINE}" || echo "0"
echo -n "  Not Applicable: "; grep -c 'result="notapplicable"' "${BASELINE}" || echo "0"
echo -n "  Not Checked:    "; grep -c 'result="notchecked"' "${BASELINE}" || echo "0"

echo ""
echo "--- POST-HARDENING SCAN ---"
echo -n "  Pass:           "; grep -c 'result="pass"' "${POST}" || echo "0"
echo -n "  Fail:           "; grep -c 'result="fail"' "${POST}" || echo "0"
echo -n "  Not Applicable: "; grep -c 'result="notapplicable"' "${POST}" || echo "0"
echo -n "  Not Checked:    "; grep -c 'result="notchecked"' "${POST}" || echo "0"

echo ""
echo "--- RULES THAT CHANGED FROM FAIL TO PASS ---"
# Extract failed rules from baseline
BASELINE_FAILS=$(grep 'result="fail"' "${BASELINE}" | grep -oP 'idref="\K[^"]+' | sort)
# Extract failed rules from post
POST_FAILS=$(grep 'result="fail"' "${POST}" | grep -oP 'idref="\K[^"]+' | sort)

# Rules fixed (were fail, now pass)
FIXED=$(comm -23 <(echo "${BASELINE_FAILS}") <(echo "${POST_FAILS}"))
FIXED_COUNT=$(echo "${FIXED}" | grep -c . || echo "0")
echo "  Total rules fixed: ${FIXED_COUNT}"

echo ""
echo "--- RULES STILL FAILING ---"
STILL_FAILING=$(comm -12 <(echo "${BASELINE_FAILS}") <(echo "${POST_FAILS}"))
STILL_FAILING_COUNT=$(echo "${STILL_FAILING}" | grep -c . || echo "0")
echo "  Total rules still failing: ${STILL_FAILING_COUNT}"

if [[ "${STILL_FAILING_COUNT}" -gt 0 ]]; then
  echo ""
  echo "  List of rules still failing:"
  echo "${STILL_FAILING}" | while read -r rule; do
    echo "    - ${rule}"
  done
fi

echo ""
echo "=== Comparison complete ==="
