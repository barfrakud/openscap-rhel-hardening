#!/usr/bin/env bash
# 03-run-baseline-scan.sh
# Run CIS Level 1 Server baseline audit with OpenSCAP
set -euo pipefail

REPORT_DIR="/var/log/openscap"
DATASTREAM="/usr/share/xml/scap/ssg/content/ssg-rhel10-ds.xml"
PROFILE="xccdf_org.ssgproject.content_profile_cis_server_l1"

mkdir -p "${REPORT_DIR}"

echo "=== Available profiles ==="
oscap info "${DATASTREAM}" 2>/dev/null | grep -A1 "Profile:"

echo ""
echo "=== Running baseline CIS L1 scan ==="
echo "Profile: ${PROFILE}"
echo "DataStream: ${DATASTREAM}"
echo ""

# Note: oscap returns non-zero exit code if any rule fails — this is expected
oscap xccdf eval \
  --profile "${PROFILE}" \
  --results "${REPORT_DIR}/baseline-results.xml" \
  --results-arf "${REPORT_DIR}/baseline-arf.xml" \
  --report "${REPORT_DIR}/baseline-report.html" \
  "${DATASTREAM}" || true

echo ""
echo "=== Scan complete ==="
echo "Reports saved to:"
ls -lh "${REPORT_DIR}"/baseline-*

echo ""
echo "Transfer the HTML report to your local machine for viewing:"
echo "  scp root@<VM_IP>:${REPORT_DIR}/baseline-report.html ."
