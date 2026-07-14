# Security Policy

Titanium-test is a security-hardened Chromium fork. **It is a personal/hobby build — not
audited, not a substitute for an official browser for high-risk use.**

## Reporting
- **Vulnerabilities in Chromium itself** → report to the [Chromium project](https://www.chromium.org/Home/chromium-security/), not here.
- **Issues in this fork's hardening layer** (a patch that weakens security, a broken mitigation)
  → open a **private** security advisory on this repo, or a regular issue if low-risk.

## Scope
This fork changes anti-fingerprinting, privacy, and network behavior via patches over
ungoogled-chromium 150. Upstream Chromium/UGC security fixes are inherited via uprevs.
