#!/usr/bin/env bash
# 04-create-tailoring.sh
# Create a tailoring file to customize the CIS L1 Server profile using autotailor
set -euo pipefail

REPORT_DIR="/var/log/openscap"
DATASTREAM="/usr/share/xml/scap/ssg/content/ssg-rhel10-ds.xml"
PROFILE="cis_server_l1"
TAILORED_PROFILE="cis_server_l1_tailored"
TAILORING_FILE="${REPORT_DIR}/tailoring.xml"

mkdir -p "${REPORT_DIR}"

echo "=== Creating tailoring file with autotailor ==="
echo "Base profile: ${PROFILE}"
echo "Tailored profile ID: ${TAILORED_PROFILE}"
echo ""

# --- Rules to disable ---
# partition_for_tmp  — VM on single partition, no separate /tmp
# partition_for_var  — VM on single partition, no separate /var
# package_httpd_removed — Apache is intentionally installed (web server role)
#
# --- Values to refine ---
# var_password_minlen: 8 -> 14 (corporate policy)
# var_accounts_maximum_age_login_defs: 365 -> 90 (CIS L2 alignment)
# var_accounts_tmout: 600 -> 900 (practical for admin sessions)

autotailor \
  --unselect=xccdf_org.ssgproject.content_rule_partition_for_tmp \
  --unselect=xccdf_org.ssgproject.content_rule_partition_for_var \
  --unselect=xccdf_org.ssgproject.content_rule_package_httpd_removed \
  --var-value=xccdf_org.ssgproject.content_value_var_password_minlen=14 \
  --var-value=xccdf_org.ssgproject.content_value_var_accounts_maximum_age_login_defs=90 \
  --var-value=xccdf_org.ssgproject.content_value_var_accounts_tmout=900 \
  --output "${TAILORING_FILE}" \
  --tailored-profile-id "${TAILORED_PROFILE}" \
  "${DATASTREAM}" \
  "${PROFILE}"

echo "Tailoring file created: ${TAILORING_FILE}"
echo ""

echo "=== Verifying tailoring file ==="
oscap info "${TAILORING_FILE}" 2>/dev/null || true

echo ""
echo "=== Quick validation — test scan with tailoring ==="
oscap xccdf eval \
  --profile "${TAILORED_PROFILE}" \
  --tailoring-file "${TAILORING_FILE}" \
  --results /tmp/tailoring-test.xml \
  "${DATASTREAM}" > /dev/null 2>&1 || true

echo "Checking disabled rules in results:"
grep -E "partition_for_tmp|partition_for_var|package_httpd_removed" /tmp/tailoring-test.xml || echo "  (rules not present — correctly notselected)"
rm -f /tmp/tailoring-test.xml

echo ""
echo "=== Done ==="
