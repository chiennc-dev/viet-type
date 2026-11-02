# Verification record

Date: 2026-11-02. Initial beta preparation on Apple Silicon, Xcode 26.4 SDK / Swift 6.3. Host: macOS 26.5.2 (25F84).

## Automated checks

| Check | Local result | Scope |
| --- | --- | --- |
| `bash scripts/test.sh` | PASS — 26 test methods | Engine, tone/case matrix, composition transitions, bounded long-token handling, installer transactions |
| `bash scripts/package.sh` | PASS | Universal input method and installer, ZIP, checksum |
| `codesign --verify --deep --strict` | PASS | Ad hoc signature integrity; does not establish Apple trust |
| `lipo -verify_arch arm64 x86_64` | PASS | Both executable slices exist; not an Intel runtime test |
| ZIP contents, CRC and SHA-256 | PASS | Includes installer, embedded input method, license and instructions |
| Workflow/issue YAML syntax | PASS | Ruby YAML parser |
| Shell syntax | PASS | Bash build, test, packaging, installation and notarization scripts |
| Installer invalid/tampered payload tests | PASS | Refuses modified payloads and preserves existing installation |
| Existing app/symlink protection | PASS | Does not overwrite foreign data or follow destination symlinks |
| GitHub CI (macOS ARM and Intel) | First Intel job PASS; ARM runner queued | Final revision results must be checked in Actions |

Installer transaction tests use temporary home folders and signed dummy executables; they do not install or launch the actual system input method.

## Native compatibility matrix

| Scenario | Status |
| --- | --- |
| Installer UI/layout | PASS on macOS 26.5.2; inspected at initial install and update |
| Actual install/update on this Mac | PASS: files copied and previous app backed up |
| Native registration/discovery | BLOCKED: service starts, but Settings does not list VietType in current login; fresh login test pending |
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

## Native session notes

The user explicitly authorized launching, installing and switching Input Sources for this test. The installer ran and installed `~/Library/Input Methods/VietType.app`, then updated it with a backup. The identifier was corrected to `dev.viettype.inputmethod.VietType`, and its connection name and installer validation now agree. The input method process starts and registers an InputMethodKit endpoint, but VietType is not available in the Settings Vietnamese list during the current login. No typing compatibility result can be claimed yet. The original ABC Input Source was not changed.

A fresh logout/login must be performed by the user after saving work. No Gatekeeper settings, quarantine attributes, or keyboard preference files were bypassed or rewritten. No Developer ID identity is available locally; notarization is therefore untested. Release automation creates drafts to prevent public binary publication before these checks are resolved.
