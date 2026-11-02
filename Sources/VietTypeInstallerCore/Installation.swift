import Foundation

public enum InstallationError: LocalizedError {
    case invalidBundle, invalidSignature, conflictingDestination
    public var errorDescription: String? {
        switch self {
        case .invalidBundle: return "Gói VietType không hợp lệ. Hãy tải lại từ trang Releases chính thức."
        case .invalidSignature: return "Chữ ký của gói VietType không hợp lệ. Không thể tiếp tục cài đặt."
        case .conflictingDestination: return "Đường dẫn cài đặt chứa dữ liệu khác hoặc liên kết. VietType sẽ không ghi đè."
        }
    }
}

/// Installs only inside the selected user's Library. No shell, sudo, network,
/// quarantine removal, or global keyboard preference edits.
public struct Installation {
    public static let bundleIdentifier = "dev.viettype.inputmethod.VietType"
    public let home: URL
    private let fileManager = FileManager.default
    public var destination: URL { home.appendingPathComponent("Library/Input Methods/VietType.app") }
    public var isInstalled: Bool { fileManager.fileExists(atPath: destination.path) }

    public init(home: URL = FileManager.default.homeDirectoryForCurrentUser) { self.home = home }

    public func install(from payload: URL) throws -> URL? {
        try validate(payload)
        try verifySignature(payload)
        if isInstalled { try validateDestination() }
        let parent = destination.deletingLastPathComponent()
        try fileManager.createDirectory(at: parent, withIntermediateDirectories: true)
        let stage = parent.appendingPathComponent(".VietType-stage-\(UUID().uuidString).app")
        defer { try? fileManager.removeItem(at: stage) }
        try fileManager.copyItem(at: payload, to: stage)
        try verifySignature(stage)
        let backup = try moveExistingToBackup()
        do {
            try fileManager.moveItem(at: stage, to: destination)
        } catch {
            if let backup { try? fileManager.moveItem(at: backup, to: destination) }
            throw error
        }
        return backup
    }

    /// Moves the app to a recoverable backup instead of deleting user data.
    public func uninstall() throws -> URL? {
        guard isInstalled else { return nil }
        try validateDestination()
        return try moveExistingToBackup()
    }

    public func validate(_ bundle: URL) throws {
        try validateBundle(bundle, allowLegacy: false)
    }

    private func validateBundle(_ bundle: URL, allowLegacy: Bool) throws {
        let plist = bundle.appendingPathComponent("Contents/Info.plist")
        guard let data = try? Data(contentsOf: plist),
              let info = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
              let identifier = info["CFBundleIdentifier"] as? String,
              (identifier == Self.bundleIdentifier || (allowLegacy && identifier == "dev.viettype.inputmethod")),
              info["CFBundleExecutable"] as? String == "VietType",
              fileManager.isExecutableFile(atPath: bundle.appendingPathComponent("Contents/MacOS/VietType").path) else {
            throw InstallationError.invalidBundle
        }
    }

    private func validateDestination() throws {
        let attributes = try fileManager.attributesOfItem(atPath: destination.path)
        guard attributes[.type] as? FileAttributeType == .typeDirectory else {
            throw InstallationError.conflictingDestination
        }
        do { try validateBundle(destination, allowLegacy: true) }
        catch { throw InstallationError.conflictingDestination }
    }

    private func moveExistingToBackup() throws -> URL? {
        guard isInstalled else { return nil }
        let backup = home.appendingPathComponent("Library/Application Support/VietType/Backups/\(UUID().uuidString)/VietType.app")
        try fileManager.createDirectory(at: backup.deletingLastPathComponent(), withIntermediateDirectories: true)
        try fileManager.moveItem(at: destination, to: backup)
        return backup
    }

    private func verifySignature(_ bundle: URL) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/codesign")
        process.arguments = ["--verify", "--deep", "--strict", bundle.path]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        try process.run()
        process.waitUntilExit()
        guard process.terminationStatus == 0 else { throw InstallationError.invalidSignature }
    }
}
