import AppKit
import InputMethodKit

let application = NSApplication.shared
application.setActivationPolicy(.prohibited)
let identifier = Bundle.main.bundleIdentifier ?? "dev.viettype.inputmethod"
let connection = Bundle.main.object(forInfoDictionaryKey: "InputMethodConnectionName") as? String
    ?? "\(identifier)_Connection"
let server = IMKServer(name: connection, bundleIdentifier: identifier)
withExtendedLifetime(server) {
    application.run()
}
