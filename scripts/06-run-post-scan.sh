#!/usr/bin/env bash
# 06-run-post-scan.sh
# Run CIS Level 1 Server scan after hardening — same params as baseline
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

echo "=== Running post-hardening CIS L1 scan ==="
echo "Profile: ${TAILORED_PROFILE}"
echo "Tailoring: ${TAILORING_FILE}"
echo ""

oscap xccdf eval \
  --profile "${TAILORED_PROFILE}" \
  --tailoring-file "${TAILORING_FILE}" \
  --results "${REPORT_DIR}/post-results.xml" \
  --results-arf "${REPORT_DIR}/post-arf.xml" \
  --report "${REPORT_DIR}/post-report.html" \
  "${DATASTREAM}" || true

echo ""
echo "=== Scan complete ==="
echo "Reports saved to:"
ls -lh "${REPORT_DIR}"/post-*

echo ""
echo "Transfer the HTML report to your local machine for viewing:"
echo "  scp root@<VM_IP>:${REPORT_DIR}/post-report.html ."
echo ""
echo "Next step: 08-compare-results.sh"
