# Contributing

Run `bash scripts/test.sh` before proposing a change. Add regression tests for conversion bugs and composition transitions. Run `bash scripts/package.sh` for release changes and verify both universal executable architectures.

Use a temporary account for native input testing. Record exact app/macOS versions and synthetic test text in `docs/QA.md`; do not claim compatibility based only on engine tests. Never include real user typing, passwords, certificates, tokens, or keychains in fixtures or issue reports.

Open an issue with a reproducible keystroke sequence, expected text, actual text, mode, macOS version, CPU architecture, and affected app/version. Use pull requests for changes; keep source independent of AppKit in VietTypeCore where possible.
