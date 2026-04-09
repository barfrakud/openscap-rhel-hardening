#!/usr/bin/env bash
# 06-run-post-scan.sh
# Run CIS Level 1 Server scan after hardening — same params as baseline
set -euo pipefail

REPORT_DIR="/root/openscap-reports"
DATASTREAM="/usr/share/xml/scap/ssg/content/ssg-rhel10-ds.xml"
TAILORING_FILE="${REPORT_DIR}/tailoring.xml"
DATE=$(date +%Y-%m-%d)

# Use tailored profile if tailoring file exists, otherwise default
if [[ -f "${TAILORING_FILE}" ]]; then
  PROFILE="cis_server_l1_tailored"
  TAILORING_OPTS="--tailoring-file ${TAILORING_FILE}"
  echo "=== Using tailored profile ==="
else
  PROFILE="cis_server_l1"
  TAILORING_OPTS=""
  echo "=== Using default profile (no tailoring file found) ==="
fi

echo "=== Running post-hardening CIS L1 scan ==="
echo "Profile: ${PROFILE}"
echo "Date: ${DATE}"
echo ""

oscap xccdf eval \
  --profile "${PROFILE}" \
  ${TAILORING_OPTS} \
  --results "${REPORT_DIR}/post-results-${DATE}.xml" \
  --results-arf "${REPORT_DIR}/post-arf-${DATE}.xml" \
  --report "${REPORT_DIR}/post-report-${DATE}.html" \
  "${DATASTREAM}" || true

echo ""
echo "=== Scan complete ==="
echo "Reports saved to:"
ls -lh "${REPORT_DIR}"/post-*-${DATE}.*

echo ""
echo "Transfer the HTML report to your local machine for viewing:"
echo "  scp root@<VM_IP>:${REPORT_DIR}/post-report-${DATE}.html ."
