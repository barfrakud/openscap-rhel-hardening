#!/usr/bin/env bash
# 01-install-packages.sh
# Install OpenSCAP scanner, SCAP Security Guide, and supporting tools
set -euo pipefail

REPORT_DIR="/var/log/openscap"

echo "=== Installing OpenSCAP and dependencies ==="

dnf install -y \
  openscap-scanner \
  openscap-utils \
  scap-security-guide \
  lynx \
  ansible-core

echo ""
echo "=== Creating report directory ==="
mkdir -p "${REPORT_DIR}"
echo "Report directory: ${REPORT_DIR}"

echo ""
echo "=== Verifying installation ==="
echo "oscap version:"
oscap --version

echo ""
echo "SSG DataStream files:"
ls -la /usr/share/xml/scap/ssg/content/ssg-rhel*-ds.xml 2>/dev/null || echo "No RHEL DataStream files found"

echo ""
echo "Available CIS profiles:"
oscap info /usr/share/xml/scap/ssg/content/ssg-rhel10-ds.xml 2>/dev/null | grep -i cis || true

echo ""
echo "=== Done ==="
