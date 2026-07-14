## What
<!-- The change + its security/privacy rationale -->

## Patch discipline
- [ ] Added as a `.patch` under `patches/<category>/` **and** a line in `patches/series` (path relative to `patches/`)
- [ ] `git apply --numstat` parses the patch (validate.yml will check)
- [ ] Built **and smoke-tested** (compile ≠ works — content-setting/net changes can DCHECK-crash at startup)
- [ ] Provenance/credit noted if lifted from another fork

## Source
<!-- upstream patch name / origin, if applicable -->
