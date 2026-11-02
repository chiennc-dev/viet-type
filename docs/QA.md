# Verification record

Date: 2026-11-02. Initial beta preparation on Apple Silicon, Xcode 26.4 SDK / Swift 6.3. Host: macOS 26.5.2 (25F84).

## Automated checks

| Check | Local result | Scope |
| --- | --- | --- |
| `bash scripts/test.sh` | PASS — 25 test methods | Engine, tone/case matrix, composition transitions, bounded long-token handling, installer transactions |
| `bash scripts/package.sh` | PASS | Universal input method and installer, ZIP, checksum |
| `codesign --verify --deep --strict` | PASS | Ad hoc signature integrity; does not establish Apple trust |
| `lipo -verify_arch arm64 x86_64` | PASS | Both executable slices exist; not an Intel runtime test |
| ZIP contents, CRC and SHA-256 | PASS | Includes installer, embedded input method, license and instructions |
| Workflow/issue YAML syntax | PASS | Ruby YAML parser |
| Shell syntax | PASS | Bash build, test, packaging, installation and notarization scripts |
| Installer invalid/tampered payload tests | PASS | Refuses modified payloads and preserves existing installation |
| Existing app/symlink protection | PASS | Does not overwrite foreign data or follow destination symlinks |
| GitHub CI (macOS ARM and Intel) | Pending first remote run | Results must be checked in Actions |

Installer transaction tests use temporary home folders and signed dummy executables; they do not install or launch the actual system input method.

## Native compatibility matrix

| Scenario | Status |
| --- | --- |
| Installer UI/layout | Pending explicit permission to launch the local ad hoc signed installer |
| Actual install/registration on this Mac | Not yet tested |
| TextEdit Telex/VNI, punctuation, Backspace, Escape | Not yet tested |
| Safari/Chrome text fields | Not yet tested |
| VS Code/Electron | Not yet tested |
| Terminal/iTerm | Not yet tested |
| Focus changes, Cmd shortcuts, selection replacement | Covered at session level; native host tests pending |
| Fresh login and reinstall/update/uninstall | Filesystem operations covered; actual OS lifecycle tests pending |
| Intel runtime | Pending CI; manual UI/input test still required |
| macOS 13/14/15 runtime | Not yet tested |
| Downloaded ZIP with Gatekeeper enabled | Not yet tested; beta lacks Developer ID/notarization |

Do not infer native application compatibility, clean-machine installation, or notarization from unit tests or compilation. Record app versions and synthetic keystrokes for manual results. Keep stable releases blocked until native checks and the signed distribution process are complete.
