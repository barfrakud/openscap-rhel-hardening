#!/usr/bin/env bash
# 02-setup-apache.sh
# Install and configure Apache with a simple test page
set -euo pipefail

echo "=== Setting up Apache web server ==="

# Create test page
cat > /var/www/html/index.html <<'EOF'
<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <title>OpenSCAP Lab</title>
</head>
<body>
    <h1>OpenSCAP Hardening Lab</h1>
    <p>This is a test page running on RHEL 10.</p>
    <p>Server is awaiting security hardening.</p>
</body>
</html>
EOF

# Enable and start Apache
systemctl enable --now httpd

# Open firewall port
firewall-cmd --permanent --add-service=http
firewall-cmd --reload

echo ""
echo "=== Verifying Apache ==="
echo "httpd status:"
systemctl is-active httpd

echo ""
echo "Firewall http service:"
firewall-cmd --list-services

echo ""
echo "Test page response:"
curl -s http://localhost | head -5

echo ""
echo "=== Apache setup complete ==="
