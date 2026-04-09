#!/usr/bin/env bash
# 01-install-packages.sh
# Install OpenSCAP scanner, SCAP Security Guide, and supporting tools
set -euo pipefail

echo "=== Installing OpenSCAP and dependencies ==="

dnf install -y \
  openscap-scanner \
  scap-security-guide \
  httpd

echo ""
echo "=== Installing Lynis (for cross-tool comparison) ==="
dnf install -y epel-release 2>/dev/null || true
dnf install -y lynis || echo "WARNING: Lynis not available — install manually later (see 09-run-lynis.sh)"

echo ""
echo "=== Verifying installation ==="
echo "oscap version:"
oscap --version

echo ""
echo "SSG DataStream files:"
ls -la /usr/share/xml/scap/ssg/content/ssg-rhel*-ds.xml 2>/dev/null || echo "No RHEL DataStream files found"

echo ""
echo "SSG Ansible playbooks:"
ls /usr/share/scap-security-guide/ansible/ 2>/dev/null | head -10 || echo "No Ansible playbooks found"

echo ""
echo "=== Done ==="
