import AppKit
import InputMethodKit
import VietTypeCore

@objc(VietTypeInputController)
final class InputController: IMKInputController {
    private var session = CompositionSession()
    private let replacementRange = NSRange(location: NSNotFound, length: 0)
    private var activeClient: IMKTextInput?

    private var savedMode: InputMode {
        InputMode(rawValue: UserDefaults.standard.string(forKey: "inputMode") ?? "") ?? .telex
    }

    override func activateServer(_ sender: Any!) {
        activeClient = sender as? IMKTextInput
        if let client = activeClient { apply(session.changeMode(to: savedMode), to: client) }
        session.restoreInvalidWords = restoreInvalidWords
    }

    override func deactivateServer(_ sender: Any!) {
        commitComposition(sender)
        activeClient = nil
    }

    override func handle(_ event: NSEvent!, client sender: Any!) -> Bool {
        guard let event, event.type == .keyDown, let client = sender as? IMKTextInput else { return false }
        activeClient = client
        if event.modifierFlags.intersection([.command, .control, .option]).isEmpty == false {
            commitComposition(sender)
            return false
        }
        if session.engine.mode != savedMode {
            apply(session.changeMode(to: savedMode), to: client)
        }
        session.restoreInvalidWords = restoreInvalidWords
        let action: CompositionAction
        switch event.keyCode {
        case 51: action = .backspace
        case 53: action = .escape
        default: action = .text(event.characters ?? "")
        }
        let result = session.process(action)
        apply(result, to: client)
        return result.handled
    }

    override func commitComposition(_ sender: Any!) {
        guard let client = (sender as? IMKTextInput) ?? activeClient else { return }
        session.restoreInvalidWords = restoreInvalidWords
        let result = session.process(.commit)
        apply(result, to: client)
    }

    private var restoreInvalidWords: Bool {
        UserDefaults.standard.object(forKey: "restoreInvalidWords") as? Bool ?? true
    }

    private func apply(_ update: CompositionUpdate, to client: IMKTextInput) {
        if let text = update.committed {
            client.insertText(text, replacementRange: replacementRange)
        }
        if let text = update.marked {
            client.setMarkedText(text,
                                 selectionRange: NSRange(location: (text as NSString).length, length: 0),
                                 replacementRange: replacementRange)
        }
    }

    override func menu() -> NSMenu! {
        let menu = NSMenu(title: "VietType")
        for mode in InputMode.allCases {
            let item = NSMenuItem(title: mode.title, action: #selector(selectMode(_:)), keyEquivalent: "")
            item.representedObject = mode.rawValue
            item.target = self
            item.state = savedMode == mode ? .on : .off
            menu.addItem(item)
        }
        menu.addItem(.separator())
        let spelling = NSMenuItem(title: "Khôi phục từ sai cấu trúc tiếng Việt", action: #selector(toggleSpelling(_:)), keyEquivalent: "")
        spelling.target = self
        spelling.state = restoreInvalidWords ? .on : .off
        menu.addItem(spelling)
        let help = NSMenuItem(title: "Escape: khôi phục phím đã gõ", action: nil, keyEquivalent: "")
        help.isEnabled = false
        menu.addItem(help)
        return menu
    }

    @objc private func selectMode(_ sender: Any) {
        // InputMethodKit dispatches actions with a command dictionary.
        let item = (sender as? NSMenuItem)
            ?? (sender as? NSDictionary)?[kIMKCommandMenuItemName] as? NSMenuItem
        guard let value = item?.representedObject as? String, let mode = InputMode(rawValue: value) else { return }
        commitComposition(activeClient)
        UserDefaults.standard.set(mode.rawValue, forKey: "inputMode")
        if let client = activeClient { apply(session.changeMode(to: mode), to: client) }
    }

    @objc private func toggleSpelling(_ sender: Any) {
        commitComposition(activeClient)
        UserDefaults.standard.set(!restoreInvalidWords, forKey: "restoreInvalidWords")
    }
}
