#!/usr/bin/env bash
# 07-apply-remediation.sh
# Apply remediation using generated Ansible playbook
set -euo pipefail

REPORT_DIR="/var/log/openscap"
REMEDIATION_YML="${REPORT_DIR}/remediation.yml"

if [[ ! -f "${REMEDIATION_YML}" ]]; then
  echo "ERROR: Remediation playbook not found: ${REMEDIATION_YML}"
  echo "Run 05-generate-fixes.sh first."
  exit 1
fi

echo "=== Pre-flight checks ==="

# Verify Ansible is installed
if ! command -v ansible-playbook &>/dev/null; then
  echo "Installing ansible-core..."
  dnf install -y ansible-core
fi

echo "Ansible version: $(ansible --version | head -1)"

# Verify connectivity
echo ""
echo "Testing Ansible connectivity..."
ansible -i "localhost," -c local all -m ping

echo ""
echo "=== Installing required Ansible collections ==="
ansible-galaxy collection install community.general ansible.posix

echo ""
echo "=== Verifying Apache and SSH before remediation ==="
echo -n "  httpd: "; systemctl is-active httpd 2>/dev/null || echo "inactive"
echo -n "  sshd:  "; systemctl is-active sshd 2>/dev/null || echo "inactive"
echo -n "  firewall http: "; firewall-cmd --query-service=http 2>/dev/null || echo "not open"

echo ""
echo "=== Applying remediation playbook ==="
echo "Playbook: ${REMEDIATION_YML}"
echo ""
ansible-playbook -i "localhost," -c local "${REMEDIATION_YML}"

echo ""
echo "=== Post-remediation checks ==="
echo -n "  httpd: "; systemctl is-active httpd 2>/dev/null || echo "inactive"
echo -n "  sshd:  "; systemctl is-active sshd 2>/dev/null || echo "inactive"
echo ""
echo "Test Apache: curl http://localhost"
echo ""
echo "Next step: 06-run-post-scan.sh"
