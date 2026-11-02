# Release procedure

## Beta builds

1. Update `VERSION` (for example `0.1.0-beta.2`), release notes, and the QA record.
2. Run `bash scripts/test.sh` and `bash scripts/package.sh`.
3. Inspect the installer, test native input on a disposable account, and record actual results in `docs/QA.md`.
4. Push the code to `main`, verify CI, then tag the same commit with `v$(cat VERSION)` and push that tag.
5. Release CI runs tests and builds on macOS ARM and Intel. Only after both pass does it publish a **prerelease** with a universal installer ZIP and SHA-256 file.

Automatic beta packages are ad hoc signed, not Developer ID signed or notarized. This must remain prominent in release notes. Stable tags deliberately fail publication through the beta workflow.

## Developer ID and notarization

Requires an Apple Developer Program account, a valid **Developer ID Application** identity in the keychain, and notarization credentials. Do not commit certificates, passwords, private keys, or exported keychains.

Store a notarytool profile interactively on the release Mac, following Apple's instructions. The profile is referenced by name, not passed as a password in repository scripts.

```bash
export SIGNING_IDENTITY='Developer ID Application: Your Name (TEAMID)'
export NOTARY_PROFILE='viettype-notary'
bash scripts/notarize.sh
```

The script builds universal binaries with hardened runtime and secure timestamps. It notarizes and staples the input method first, embeds that copy into the installer, signs/notarizes/staples the installer, assesses Gatekeeper, then recreates the final ZIP and checksum. This command submits software to Apple's service; run it only with your own configured credentials.

Before a stable release, set a numeric release `VERSION`, update `CFBundleShortVersionString` and increment `CFBundleVersion` in both plist files. Complete the compatibility matrix, test the ZIP downloaded from GitHub with Gatekeeper enabled on a clean Mac/account, verify `spctl` and `stapler`, then publish the exact checked ZIP manually using `gh release create` or GitHub's Releases UI. Do not upload the automatic beta artifact as a stable package.

Useful checks:

```bash
codesign --verify --deep --strict 'dist/VietType Installer.app'
xcrun stapler validate dist/VietType.app
xcrun stapler validate 'dist/VietType Installer.app'
spctl --assess --type execute --verbose 'dist/VietType Installer.app'
lipo -archs dist/VietType.app/Contents/MacOS/VietType
```

Apple references: [Notarizing macOS software](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution), [distribution outside the Mac App Store](https://help.apple.com/xcode/mac/current/en.lproj/dev033e997ca.html).
