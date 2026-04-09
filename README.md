# OpenSCAP RHEL Hardening Lab

> **Series:** Security & Compliance — Lab 1  
> **Platform:** Red Hat Enterprise Linux 10.1 (Coughlan)  
> **Tools:** OpenSCAP v1.4.3, scap-security-guide, Ansible, Lynis v3.1.6  
> **Profile:** CIS Benchmark Level 1 — Server  

## Project Goal

Hands-on lab demonstrating a full **security compliance audit and hardening cycle** on RHEL 10 using OpenSCAP. The project covers:

- Running a baseline CIS compliance scan on a fresh RHEL 10 install
- Analyzing the audit report and understanding failure categories
- Creating a tailoring file to customize the CIS profile
- Applying automated remediation (Ansible playbook)
- Re-running the scan and measuring improvement
- Documenting exceptions with formal justification

## Lab Scenario

A freshly installed RHEL 10 server hosts a simple Apache web application. The system must meet **CIS Benchmark Level 1 (Server)** compliance.

The lab walks through the full audit → tailoring → remediation → re-audit → exceptions cycle.

## Project Structure

```
openscap-rhel-hardening-lab/
├── README.md                    # This file
├── LAB_RULES.md                 # Lab rules, conventions, methodology
├── docs/
│   ├── 01-theory.md             # OpenSCAP theory, SCAP standard, profiles
│   ├── 02-environment-setup.md  # VM preparation, RHEL install, Apache setup
│   ├── 03-baseline-audit.md     # First scan — commands, results, analysis
│   ├── 04-tailoring.md          # Profile customization — tailoring file
│   ├── 05-remediation.md        # Hardening — fix generation, review, Ansible
│   ├── 06-post-audit.md         # Second scan — comparison, improvements
│   ├── 07-exceptions.md         # Exception register — formal waivers
│   ├── 08-summary.md            # Conclusions, lessons learned, next steps
│   └── 09-lynis-comparison.md   # Lynis audit — cross-tool comparison
├── scripts/
│   ├── 01-install-packages.sh   # Install OpenSCAP + dependencies
│   ├── 02-setup-apache.sh       # Install & configure Apache + test page
│   ├── 03-run-baseline-scan.sh  # Run first CIS audit (baseline)
│   ├── 04-create-tailoring.sh   # Create tailoring file with autotailor
│   ├── 05-generate-fixes.sh     # After-tailoring scan + generate fixes
│   ├── 06-run-post-scan.sh      # Run post-hardening audit
│   ├── 07-apply-remediation.sh  # Apply Ansible remediation playbook
│   ├── 08-compare-results.sh    # Compare baseline vs post-hardening
│   └── 09-run-lynis.sh          # Run Lynis audit for comparison
├── remediation/
│   ├── remediation.sh           # Generated bash remediation script
│   └── remediation.yml          # Generated Ansible remediation playbook
├── ansible/
│   └── inventory.ini            # Ansible inventory for lab VM
├── reports/                     # Audit reports (HTML) — for reference
│   └── .gitkeep
└── assets/                      # Screenshots, diagrams
    └── .gitkeep
```

## Prerequisites

- RHEL 10 VM (Minimal Install)
- Active Red Hat subscription (free Developer Subscription is fine)
- Root or sudo access
- Internet connectivity for package installation
- min. 2 GB RAM, min. 20 GB disk

## Architecture

```mermaid
flowchart TD
    A["RHEL 10 VM\n+ Apache"] --> B["Baseline Scan\n(CIS L1 Server)"]
    B --> C["Tailoring\n(autotailor)"]
    C --> D["After-Tailoring Scan"]
    D --> E["Generate Fixes\n(bash + Ansible)"]
    E --> F["Review + Apply\n(Ansible playbook)"]
    F --> G["Post-Hardening Scan"]
    G --> H["Exception Register"]
```

## Quick Start

```bash
# 1. Clone the repo
git clone https://github.com/barfrakud/openscap-rhel-hardening-lab

# 2. Copy scripts to your RHEL 10 VM and run step by step:
sudo bash scripts/01-install-packages.sh
sudo bash scripts/02-setup-apache.sh
sudo bash scripts/03-run-baseline-scan.sh
sudo bash scripts/04-create-tailoring.sh
sudo bash scripts/05-generate-fixes.sh
sudo bash scripts/07-apply-remediation.sh
sudo bash scripts/06-run-post-scan.sh
sudo bash scripts/08-compare-results.sh

# See docs/ for detailed walkthrough of each step
```

## Results

| Metric                 | Baseline Scan | Post-Hardening Scan | Change       |
|------------------------|---------------|---------------------|--------------|
| **Score**              | 73.99%        | **95.45%**          | +21.46 pp    |
| Rules pass             | 170           | 283                 | +113         |
| Rules fail             | 119           | 5                   | −114         |
| Rules notapplicable    | 32            | 31                  | −1           |
| **Fix rate**           |               |                     | **95.8%**    |

**Tailoring:** 3 rules disabled, 3 values refined  
**Exceptions:** 5 active (GRUB2 password, SSH AllowUsers, password last change, journald+rsyslog, journal-upload)  
**Remediation:** Ansible playbook — ok=1193, changed=155, failed=0

### Key Takeaways

- **Automated remediation works well at scale.** A single Ansible playbook run resolved 114 out of 119 failing rules (95.8%), requiring no manual intervention on individual controls. This validates the generate → review → apply workflow as effective for real-world hardening.
- **A 73.99% baseline is typical for a freshly installed RHEL system.** Most failures are not misconfigurations but simply features that are off-by-default and need deliberate hardening (e.g., audit rules, PAM settings, kernel parameters). This underscores that default OS installs are not compliance-ready out of the box.
- **The remaining 5 failures are intentional, not oversights.** Each maps to a formally documented exception with a business justification — GRUB2 bootloader password is incompatible with cloud/VM provisioning workflows; SSH AllowUsers is managed at the infrastructure level; journald/rsyslog conflict stems from running both logging stacks simultaneously for compatibility reasons.
- **Tailoring is essential for operational realism.** Applying CIS Level 1 verbatim to a server running Apache would break legitimate services. The 3 tailored rules (and 3 refined values) reflect the gap between a generic benchmark and a real deployment context.
- **95.45% is a strong result for a production-like workload.** Most compliance frameworks accept a small number of formally justified exceptions. Reaching this score with zero Ansible failures demonstrates that the remediation playbook generated by OpenSCAP is production-safe when reviewed before execution.

## OpenSCAP vs Lynis

| | OpenSCAP | Lynis |
|---|---|---|
| **Approach** | Compliance-driven (pass/fail vs standard) | Advisory-driven (scoring + suggestions) |
| **Score after hardening** | **95.45%** (CIS L1 score) | **72**/100 (Hardening Index) |
| **Purpose** | Formal audit, reports for auditors, auto-remediation | Quick assessment, discovering issues outside CIS scope |
| **Unique findings** | GRUB2 password, PAM faillock, journald/rsyslog conflict | mod_evasive, modsecurity, malware scanner, compiler |

**Conclusion:** OpenSCAP answers the question *"is the system compliant with the standard?"* — Lynis answers the question *"what else can be improved?"*. The tools complement each other.

## References

- [OpenSCAP Documentation](https://www.open-scap.org/documentation/)
- [SCAP Security Guide (SSG)](https://github.com/ComplianceAsCode/content)
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks)
- [DISA STIG](https://public.cyber.mil/stigs/)
- [Red Hat — Security Compliance](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/security_hardening/)

## License

MIT
