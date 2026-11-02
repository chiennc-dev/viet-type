import AppKit
import Carbon
import VietTypeInstallerCore

final class InstallerDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow!
    private var status: NSTextField!
    private var installButton: NSButton!
    private let installation = Installation()
    private let releaseURL = URL(string: "https://github.com/chiennc-dev/viet-type/releases")!

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 570, height: 460),
                          styleMask: [.titled, .closable, .miniaturizable], backing: .buffered, defer: false)
        window.title = "Cài đặt VietType"
        window.isReleasedWhenClosed = false
        window.center()
        let content = NSStackView()
        content.orientation = .vertical
        content.alignment = .leading
        content.spacing = 18
        content.edgeInsets = NSEdgeInsets(top: 28, left: 30, bottom: 28, right: 30)
        content.translatesAutoresizingMaskIntoConstraints = false
        window.contentView!.addSubview(content)
        NSLayoutConstraint.activate([
            content.leadingAnchor.constraint(equalTo: window.contentView!.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: window.contentView!.trailingAnchor),
            content.topAnchor.constraint(equalTo: window.contentView!.topAnchor)
        ])
        let title = NSTextField(labelWithString: "Gõ tiếng Việt trên Mac")
        title.font = .boldSystemFont(ofSize: 27)
        content.addArrangedSubview(title)
        let intro = label("Telex và VNI · macOS 13+ · Intel và Apple Silicon\nCài cho tài khoản hiện tại, không cần quyền quản trị.")
        content.addArrangedSubview(intro)
        status = label(installation.isInstalled
            ? "Đã có VietType. Chuyển sang bộ gõ khác trước khi cập nhật hoặc gỡ. Bản cũ được giữ để khôi phục."
            : "1. Nhấn Cài đặt.\n2. Mở cài đặt bàn phím và thêm VietType.\n3. Chọn Telex hoặc VNI trong menu bộ gõ.")
        content.addArrangedSubview(status)
        installButton = NSButton(title: installation.isInstalled ? "Cập nhật VietType" : "Cài đặt VietType",
                                 target: self, action: #selector(install))
        installButton.bezelStyle = .rounded
        installButton.keyEquivalent = "\r"
        content.addArrangedSubview(installButton)
        let settings = NSButton(title: "Mở cài đặt bàn phím", target: self, action: #selector(openSettings))
        settings.bezelStyle = .rounded
        content.addArrangedSubview(settings)
        let row = NSStackView()
        row.spacing = 20
        row.addArrangedSubview(NSButton(title: "Gỡ VietType…", target: self, action: #selector(uninstall)))
        row.addArrangedSubview(NSButton(title: "Hướng dẫn & cập nhật", target: self, action: #selector(openReleases)))
        content.addArrangedSubview(row)
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func label(_ text: String) -> NSTextField {
        let field = NSTextField(wrappingLabelWithString: text)
        field.font = .systemFont(ofSize: 14)
        field.preferredMaxLayoutWidth = 510
        field.widthAnchor.constraint(equalToConstant: 510).isActive = true
        return field
    }

    @objc private func install() {
        guard let payload = Bundle.main.resourceURL?.appendingPathComponent("VietType.app") else { return }
        do {
            let backup = try installation.install(from: payload)
            let result = TISRegisterInputSource(installation.destination as CFURL)
            status.stringValue = "Đã cài VietType. Mở cài đặt bàn phím → Text Input → Edit → + → Vietnamese → VietType. Nếu chưa thấy bộ gõ, hãy đăng xuất rồi đăng nhập lại."
                + (backup == nil ? "" : "\nBản cũ đã được sao lưu.")
                + (result == noErr ? "" : "\nmacOS chưa đăng ký bộ gõ (mã \(result)); cần đăng xuất/đăng nhập lại.")
            installButton.title = "Cài lại VietType"
        } catch {
            showError(error)
        }
    }

    @objc private func uninstall() {
        let alert = NSAlert()
        alert.messageText = "Gỡ VietType khỏi tài khoản này?"
        alert.informativeText = "Hãy chuyển sang bộ gõ khác và bỏ VietType trong cài đặt bàn phím trước khi gỡ. Ứng dụng sẽ được chuyển vào thư mục Backups để có thể khôi phục."
        alert.addButton(withTitle: "Hủy")
        alert.addButton(withTitle: "Gỡ VietType")
        guard alert.runModal() == .alertSecondButtonReturn else { return }
        do {
            let backup = try installation.uninstall()
            status.stringValue = backup == nil ? "VietType chưa được cài trên tài khoản này."
                : "Đã gỡ VietType. Hãy đăng xuất rồi đăng nhập lại để macOS dừng phiên bộ gõ cũ. Bản sao lưu nằm trong ~/Library/Application Support/VietType/Backups."
            installButton.title = "Cài đặt VietType"
        } catch { showError(error) }
    }

    private func showError(_ error: Error) {
        let alert = NSAlert(error: error)
        alert.runModal()
    }

    @objc private func openSettings() {
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.Keyboard-Settings.extension")!)
    }

    @objc private func openReleases() { NSWorkspace.shared.open(releaseURL) }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
}

if CommandLine.arguments.contains("--install") || CommandLine.arguments.contains("--uninstall") {
    let installation = Installation()
    do {
        if CommandLine.arguments.contains("--install") {
            let payload = Bundle.main.resourceURL!.appendingPathComponent("VietType.app")
            let backup = try installation.install(from: payload)
            let result = TISRegisterInputSource(installation.destination as CFURL)
            print("Installed: \(installation.destination.path)")
            if let backup { print("Backup: \(backup.path)") }
            print("Input Source registration: \(result). Log out and back in, then add VietType in Keyboard settings.")
        } else {
            let backup = try installation.uninstall()
            print(backup.map { "Moved to: \($0.path)" } ?? "VietType is not installed.")
        }
        exit(EXIT_SUCCESS)
    } catch {
        fputs("\(error.localizedDescription)\n", stderr)
        exit(EXIT_FAILURE)
    }
}

let app = NSApplication.shared
let delegate = InstallerDelegate()
app.delegate = delegate
app.run()
