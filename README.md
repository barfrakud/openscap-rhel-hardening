# OpenSCAP RHEL Hardening Lab

> **Series:** Security & Compliance — Lab 1  
> **Author:** Bartek  
> **Platform:** Red Hat Enterprise Linux 10  
> **Tools:** OpenSCAP, scap-security-guide, Ansible  

## 🎯 Project Goal

Hands-on lab demonstrating a full **security compliance audit and hardening cycle** on RHEL 10 using OpenSCAP. The project covers:

- Running a baseline CIS compliance scan on a fresh RHEL 10 install
- Analyzing the audit report and understanding failure categories
- Applying automated remediation (bash scripts + Ansible)
- Re-running the scan and measuring improvement
- Documenting findings and lessons learned

## 📋 Lab Scenario

A freshly installed RHEL 10 server hosts a simple Apache web application. The system must meet **CIS Benchmark Level 1 (Server)** compliance. The lab walks through the full audit → remediation → re-audit cycle.

## 🗂️ Project Structure

```
openscap-rhel-hardening-lab/
├── README.md                    # This file
├── CLAUDE.md                    # AI assistant context & project rules
├── LAB_RULES.md                 # Lab rules, conventions, methodology
├── docs/
│   ├── 01-theory.md             # OpenSCAP theory, SCAP standard, profiles
│   ├── 02-environment-setup.md  # VM preparation, RHEL install, Apache setup
│   ├── 03-baseline-audit.md     # First scan — commands, results, analysis
│   ├── 04-remediation.md        # Hardening steps, scripts, Ansible playbook
│   ├── 05-post-audit.md         # Second scan — comparison, improvements
│   ├── 06-summary.md            # Conclusions, lessons learned, next steps
│   └── glossary.md              # Key terms: XCCDF, OVAL, STIG, CIS, ARF...
├── scripts/
│   ├── 01-install-packages.sh   # Install OpenSCAP + dependencies
│   ├── 02-setup-apache.sh       # Install & configure Apache + sample page
│   ├── 03-run-baseline-scan.sh  # Run first CIS audit
│   ├── 04-generate-fixes.sh     # Generate remediation scripts from results
│   ├── 05-run-post-scan.sh      # Run second audit after hardening
│   └── 06-compare-results.sh    # Compare baseline vs post-hardening results
├── ansible/
│   ├── remediation.yml          # Generated/custom hardening playbook
│   └── inventory.ini            # Ansible inventory for lab VM
├── reports/                     # Audit reports (HTML/XML) — gitignored
│   └── .gitkeep
└── assets/                      # Screenshots, diagrams for documentation
    └── .gitkeep
```

## 🔧 Prerequisites

- RHEL 10 VM (Minimal Install or Server)
- Active Red Hat subscription (free Developer Subscription is fine)
- Root or sudo access
- Internet connectivity for package installation
- ~2 GB RAM, ~20 GB disk recommended

## 🚀 Quick Start

```bash
# 1. Clone the repo
git clone https://github.com/<your-username>/openscap-rhel-hardening-lab.git

# 2. Copy scripts to your RHEL 10 VM and execute step by step
# See docs/ for detailed walkthrough
```

## 📊 Expected Results

| Metric              | Baseline Scan | Post-Hardening Scan |
|----------------------|---------------|---------------------|
| CIS L1 Pass Rate     | ~40-60%       | ~85-95%             |
| CAT I Failures       | Several       | 0                   |
| Total Rules Checked  | ~150-200      | ~150-200            |

*(Actual numbers will be filled in during the lab)*

## 🔗 Related Projects

- Docker 5 Tasks (Vol. 1) — containerization fundamentals
- *(Planned)* Ansible 5 Tasks — configuration management

## 📚 References

- [OpenSCAP Documentation](https://www.open-scap.org/documentation/)
- [SCAP Security Guide (SSG)](https://github.com/ComplianceAsCode/content)
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks)
- [DISA STIG](https://public.cyber.mil/stigs/)
- [Red Hat — Security Compliance](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/security_hardening/)

## 📝 License

MIT
