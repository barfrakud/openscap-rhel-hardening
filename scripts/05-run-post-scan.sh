#!/usr/bin/env bash
# 05-run-post-scan.sh
# Run CIS Level 1 Server scan after hardening — same params as baseline
set -euo pipefail

REPORT_DIR="/root/openscap-reports"
DATASTREAM="/usr/share/xml/scap/ssg/content/ssg-rhel10-ds.xml"
PROFILE="cis_server_l1"
DATE=$(date +%Y-%m-%d)

echo "=== Running post-hardening CIS L1 scan ==="
echo "Profile: ${PROFILE}"
echo "Date: ${DATE}"
echo ""

oscap xccdf eval \
  --profile "${PROFILE}" \
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
