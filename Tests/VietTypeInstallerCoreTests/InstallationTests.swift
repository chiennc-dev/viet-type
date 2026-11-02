import XCTest
@testable import VietTypeInstallerCore

final class InstallationTests: XCTestCase {
    private var root: URL!
    private var installation: Installation!
    private let fm = FileManager.default

    override func setUpWithError() throws {
        root = fm.temporaryDirectory.appendingPathComponent("VietType tests \(UUID().uuidString)")
        try fm.createDirectory(at: root, withIntermediateDirectories: true)
        installation = Installation(home: root.appendingPathComponent("Test Home"))
    }

    override func tearDownWithError() throws { try fm.removeItem(at: root) }

    private func payload(_ name: String = "Payload.app", marker: String = "original") throws -> URL {
        let app = root.appendingPathComponent(name)
        let macOS = app.appendingPathComponent("Contents/MacOS")
        try fm.createDirectory(at: macOS, withIntermediateDirectories: true)
        try fm.createDirectory(at: app.appendingPathComponent("Contents/Resources"), withIntermediateDirectories: true)
        try fm.copyItem(at: URL(fileURLWithPath: "/usr/bin/true"), to: macOS.appendingPathComponent("VietType"))
        let info: [String: Any] = ["CFBundleIdentifier": Installation.bundleIdentifier,
                                   "CFBundleExecutable": "VietType", "CFBundlePackageType": "APPL"]
        try PropertyListSerialization.data(fromPropertyList: info, format: .xml, options: 0)
            .write(to: app.appendingPathComponent("Contents/Info.plist"))
        try marker.write(to: app.appendingPathComponent("Contents/Resources/marker.txt"), atomically: true, encoding: .utf8)
        let sign = Process()
        sign.executableURL = URL(fileURLWithPath: "/usr/bin/codesign")
        sign.arguments = ["--force", "--sign", "-", app.path]
        try sign.run()
        sign.waitUntilExit()
        XCTAssertEqual(sign.terminationStatus, 0)
        return app
    }

    func testFirstInstallAndIdempotentUninstall() throws {
        let original = try payload()
        XCTAssertNil(try installation.install(from: original))
        XCTAssertTrue(installation.isInstalled)
        let backup = try XCTUnwrap(installation.uninstall())
        XCTAssertFalse(installation.isInstalled)
        XCTAssertTrue(fm.fileExists(atPath: backup.path))
        XCTAssertTrue(fm.fileExists(atPath: original.path))
        XCTAssertNil(try installation.uninstall())
    }

    func testUpdatePreservesOldAppAndInstallsNewVersion() throws {
        _ = try installation.install(from: payload())
        let backup = try XCTUnwrap(installation.install(from: payload("Updated.app", marker: "updated")))
        XCTAssertEqual(try String(contentsOf: backup.appendingPathComponent("Contents/Resources/marker.txt")), "original")
        XCTAssertEqual(try String(contentsOf: installation.destination.appendingPathComponent("Contents/Resources/marker.txt")), "updated")
        XCTAssertFalse(backup.path.contains("Input Methods"))
    }

    func testInvalidPayloadDoesNotTouchInstalledVersion() throws {
        _ = try installation.install(from: payload())
        XCTAssertThrowsError(try installation.install(from: root.appendingPathComponent("Missing.app")))
        XCTAssertEqual(try String(contentsOf: installation.destination.appendingPathComponent("Contents/Resources/marker.txt")), "original")
    }

    func testTamperedSignatureIsRejected() throws {
        let app = try payload()
        try "tampered".write(to: app.appendingPathComponent("Contents/Resources/marker.txt"), atomically: true, encoding: .utf8)
        XCTAssertThrowsError(try installation.install(from: app))
        XCTAssertFalse(installation.isInstalled)
    }

    func testForeignDestinationIsNotOverwrittenOrRemoved() throws {
        try fm.createDirectory(at: installation.destination, withIntermediateDirectories: true)
        let marker = installation.destination.appendingPathComponent("keep.txt")
        try "keep".write(to: marker, atomically: true, encoding: .utf8)
        XCTAssertThrowsError(try installation.install(from: payload()))
        XCTAssertThrowsError(try installation.uninstall())
        XCTAssertEqual(try String(contentsOf: marker), "keep")
    }

    func testSymbolicLinkIsNotFollowed() throws {
        let app = try payload()
        try fm.createDirectory(at: installation.destination.deletingLastPathComponent(), withIntermediateDirectories: true)
        try fm.createSymbolicLink(at: installation.destination, withDestinationURL: app)
        XCTAssertThrowsError(try installation.install(from: app))
        XCTAssertThrowsError(try installation.uninstall())
        XCTAssertTrue(fm.fileExists(atPath: app.path))
    }

    func testBundleMetadataMatchesInstallerAndIMKConnection() throws {
        let project = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent()
        let data = try Data(contentsOf: project.appendingPathComponent("Resources/Info.plist"))
        let info = try XCTUnwrap(PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any])
        let identifier = try XCTUnwrap(info["CFBundleIdentifier"] as? String)
        XCTAssertTrue(identifier.contains(".inputmethod."))
        XCTAssertEqual(identifier, Installation.bundleIdentifier)
        XCTAssertEqual(info["TISInputSourceID"] as? String, identifier)
        XCTAssertEqual(info["InputMethodConnectionName"] as? String, "\(identifier)_Connection")
        XCTAssertEqual(info["CFBundleExecutable"] as? String, "VietType")
    }
}
