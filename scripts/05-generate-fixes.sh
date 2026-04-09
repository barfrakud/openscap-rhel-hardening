#!/usr/bin/env bash
# 05-generate-fixes.sh
# Run after-tailoring scan, then generate remediation scripts from DataStream
set -euo pipefail

REPORT_DIR="/var/log/openscap"
DATASTREAM="/usr/share/xml/scap/ssg/content/ssg-rhel10-ds.xml"
TAILORING_FILE="${REPORT_DIR}/tailoring.xml"
TAILORED_PROFILE="cis_server_l1_tailored"

if [[ ! -f "${TAILORING_FILE}" ]]; then
  echo "ERROR: Tailoring file not found: ${TAILORING_FILE}"
  echo "Run 04-create-tailoring.sh first."
  exit 1
fi

echo "=== Step 1: After-tailoring scan (pre-remediation baseline) ==="
oscap xccdf eval \
  --profile "${TAILORED_PROFILE}" \
  --tailoring-file "${TAILORING_FILE}" \
  --results "${REPORT_DIR}/after-tailoring-results.xml" \
  --results-arf "${REPORT_DIR}/after-tailoring-arf.xml" \
  --report "${REPORT_DIR}/after-tailoring-report.html" \
  "${DATASTREAM}" || true

echo ""
echo "After-tailoring report: ${REPORT_DIR}/after-tailoring-report.html"

echo ""
echo "=== Step 2: Generating Bash remediation script ==="
oscap xccdf generate fix \
  --fix-type bash \
  --profile "${TAILORED_PROFILE}" \
  --tailoring-file "${TAILORING_FILE}" \
  --output "${REPORT_DIR}/remediation.sh" \
  "${DATASTREAM}"
echo "Saved: ${REPORT_DIR}/remediation.sh"

echo ""
echo "=== Step 3: Generating Ansible remediation playbook ==="
oscap xccdf generate fix \
  --fix-type ansible \
  --profile "${TAILORED_PROFILE}" \
  --tailoring-file "${TAILORING_FILE}" \
  --output "${REPORT_DIR}/remediation.yml" \
  "${DATASTREAM}"
echo "Saved: ${REPORT_DIR}/remediation.yml"

echo ""
echo "=== Generated files ==="
ls -lh "${REPORT_DIR}"/remediation.*

echo ""
echo "IMPORTANT: Review the scripts before running them!"
echo "  less ${REPORT_DIR}/remediation.sh"
echo "  less ${REPORT_DIR}/remediation.yml"
echo ""
echo "Next step: 07-apply-remediation.sh"
