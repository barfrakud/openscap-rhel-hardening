#!/usr/bin/env bash
# 04-generate-fixes.sh
# Generate remediation scripts from baseline scan results
set -euo pipefail

REPORT_DIR="/root/openscap-reports"
DATE=$(date +%Y-%m-%d)

# Find the most recent ARF file
ARF_FILE=$(ls -t "${REPORT_DIR}"/baseline-arf-*.xml 2>/dev/null | head -1)

if [[ -z "${ARF_FILE}" ]]; then
  echo "ERROR: No baseline ARF file found in ${REPORT_DIR}"
  echo "Run 03-run-baseline-scan.sh first."
  exit 1
fi

echo "=== Using ARF file: ${ARF_FILE} ==="

echo ""
echo "=== Generating Bash remediation script ==="
oscap xccdf generate fix \
  --fix-type bash \
  --result-id "" \
  --output "${REPORT_DIR}/remediation-${DATE}.sh" \
  "${ARF_FILE}"
echo "Saved: ${REPORT_DIR}/remediation-${DATE}.sh"

echo ""
echo "=== Generating Ansible remediation playbook ==="
oscap xccdf generate fix \
  --fix-type ansible \
  --result-id "" \
  --output "${REPORT_DIR}/remediation-${DATE}.yml" \
  "${ARF_FILE}"
echo "Saved: ${REPORT_DIR}/remediation-${DATE}.yml"

echo ""
echo "=== Generated files ==="
ls -lh "${REPORT_DIR}"/remediation-${DATE}.*

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║  IMPORTANT: Review the scripts before running them! ║"
echo "║  Make a VM snapshot before applying any fixes!       ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
echo "To review:"
echo "  less ${REPORT_DIR}/remediation-${DATE}.sh"
echo "  less ${REPORT_DIR}/remediation-${DATE}.yml"
