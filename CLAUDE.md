# CLAUDE.md — Project Context for AI Assistant

## Project Overview

This is a **hands-on security compliance lab** for learning OpenSCAP on RHEL 10.
The project is part of a DevOps/Linux Admin portfolio and will be published on GitHub.

## What This Project Is

- An educational lab with step-by-step documentation
- A portfolio piece demonstrating security compliance skills
- A practical exercise: audit → tailoring → hardening → re-audit cycle on RHEL 10
- Uses CIS Benchmark Level 1 (Server) profile as the compliance target
- Includes commercial elements: tailoring file, exception register, Lynis comparison

## Tech Stack

- **OS:** Red Hat Enterprise Linux 10
- **Audit tool:** OpenSCAP (`oscap` CLI + `scap-security-guide`)
- **Remediation:** Bash scripts + Ansible playbooks
- **Web server:** Apache httpd (simple test page, serves as "workload")
- **Profile:** CIS Level 1 Server (`cis_server_l1`), tailored variant (`cis_server_l1_tailored`)
- **Comparison tool:** Lynis (heuristic audit)

## Key Conventions

### Documentation
- All docs are in `docs/` as numbered Markdown files (01-09 + glossary)
- Write in **Polish** — this is the author's primary language
- Include exact commands that were run and their output (truncated if very long)
- Note every decision: what was done, why, and what was the result
- Screenshots of HTML reports go in `assets/`

### Scripts
- All scripts in `scripts/` are **numbered** and meant to be run sequentially
- Scripts must be idempotent where possible
- Every script starts with a comment block explaining its purpose
- Use `set -euo pipefail` in all bash scripts
- Target path for reports: `/root/openscap-reports/`

### Ansible
- Playbooks in `ansible/` target `localhost` by default
- Use `ansible-playbook -c local` for local execution on the VM

### Git
- `reports/` directory is gitignored (contains large XML/HTML files)
- Commit after each major step (setup, baseline scan, remediation, post-scan)
- Use conventional commits: `docs:`, `feat:`, `fix:`, `chore:`

## File Naming

- Docs: `NN-descriptive-name.md` (e.g., `03-baseline-audit.md`)
- Scripts: `NN-descriptive-name.sh` (e.g., `03-run-baseline-scan.sh`)
- Reports: `baseline-scan-YYYY-MM-DD.html`, `post-scan-YYYY-MM-DD.html`

## Workflow

1. Each step is documented BEFORE and AFTER execution
2. Run command → capture output → paste into doc → analyze
3. Never run full remediation blindly — review generated fixes first
4. Always explain WHY a rule passed or failed, not just the status

## Important Paths on RHEL 10 VM

- SSG content: `/usr/share/xml/scap/ssg/content/`
- SSG Ansible: `/usr/share/scap-security-guide/ansible/`
- DataStream file: `/usr/share/xml/scap/ssg/content/ssg-rhel10-ds.xml`
- Reports output: `/root/openscap-reports/`
- Tailoring file: `/root/openscap-reports/tailoring.xml`

## Do NOT

- Do not hardcode passwords or sensitive data in scripts
- Do not commit HTML/XML report files (they are large and contain system details)
- Do not apply STIG profile — we use CIS L1 for this lab
- Do not skip documentation steps — the learning process IS the deliverable
- Do not delete tailoring.xml — it is used by scripts 05, 06
