import AppKit
import InputMethodKit

let application = NSApplication.shared
application.setActivationPolicy(.prohibited)
let identifier = Bundle.main.bundleIdentifier ?? "dev.viettype.inputmethod.VietType"
let connection = Bundle.main.object(forInfoDictionaryKey: "InputMethodConnectionName") as? String
    ?? "\(identifier)_Connection"
guard let server = IMKServer(name: connection, bundleIdentifier: identifier) else {
    fputs("VietType: could not create the InputMethodKit server.\n", stderr)
    exit(EXIT_FAILURE)
}
withExtendedLifetime(server) {
    application.run()
}
