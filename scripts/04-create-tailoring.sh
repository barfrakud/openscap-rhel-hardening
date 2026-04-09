#!/usr/bin/env bash
# 04-create-tailoring.sh
# Create a tailoring file to customize the CIS L1 Server profile
set -euo pipefail

REPORT_DIR="/root/openscap-reports"
DATASTREAM="/usr/share/xml/scap/ssg/content/ssg-rhel10-ds.xml"
PROFILE="cis_server_l1"
TAILORED_PROFILE="cis_server_l1_tailored"
TAILORING_FILE="${REPORT_DIR}/tailoring.xml"

mkdir -p "${REPORT_DIR}"

echo "=== Creating tailoring file ==="
echo "Base profile: ${PROFILE}"
echo "Tailored profile ID: ${TAILORED_PROFILE}"
echo ""

# Generate base tailoring file from the profile
oscap xccdf generate tailoring \
  --profile "${PROFILE}" \
  --new-profile-id "${TAILORED_PROFILE}" \
  --output "${TAILORING_FILE}" \
  "${DATASTREAM}"

echo "Tailoring file created: ${TAILORING_FILE}"
echo ""

echo "=== Verifying tailoring file ==="
oscap info "${TAILORING_FILE}" 2>/dev/null || true

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║  Next steps:                                                 ║"
echo "║  1. Edit ${TAILORING_FILE}  ║"
echo "║     - Disable rules that cannot be fixed (e.g. partitions)   ║"
echo "║     - Adjust parameter values to match your policy           ║"
echo "║  2. Validate: oscap info ${TAILORING_FILE}  ║"
echo "║  3. Test scan with tailoring:                                ║"
echo "║     oscap xccdf eval --profile ${TAILORED_PROFILE} \\        ║"
echo "║       --tailoring-file ${TAILORING_FILE} \\                  ║"
echo "║       ${DATASTREAM}                                          ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
