import Foundation

/// One input session. The host applies commits before marked text and forwards
/// an event exactly once when `handled` is false.
public struct CompositionUpdate: Equatable {
    public var committed: String? = nil
    public var marked: String? = nil
    public var handled = false
}

public enum CompositionAction {
    case text(String)
    case backspace
    case escape
    case commit
}

public struct CompositionSession {
    public private(set) var engine: TypingEngine
    public var restoreInvalidWords = true
    public init(mode: InputMode = .telex) { engine = TypingEngine(mode: mode) }

    public mutating func changeMode(to mode: InputMode) -> CompositionUpdate {
        let result = process(.commit)
        engine.changeMode(to: mode)
        return result
    }

    public mutating func process(_ action: CompositionAction) -> CompositionUpdate {
        switch action {
        case .backspace:
            guard !engine.isEmpty else { return CompositionUpdate() }
            engine.backspace()
            return CompositionUpdate(marked: engine.text, handled: true)
        case .escape:
            guard !engine.isEmpty else { return CompositionUpdate() }
            let literal = engine.rawInput
            engine.reset()
            return CompositionUpdate(committed: literal, handled: true)
        case .commit:
            guard !engine.isEmpty else { return CompositionUpdate() }
            let text = engine.committedText(restoreInvalidWords: restoreInvalidWords)
            engine.reset()
            return CompositionUpdate(committed: text)
        case .text(let text):
            guard text.count == 1, let character = text.first, let ascii = character.asciiValue else {
                return process(.commit)
            }
            let letter = (65...90).contains(ascii) || (97...122).contains(ascii)
            let digit = engine.mode == .vni && (48...57).contains(ascii) && !engine.isEmpty
            guard letter || digit else { return process(.commit) }
            // Bound conversion work even if a host sends a very long token.
            var committed: String?
            if engine.rawInput.count >= 128 { committed = process(.commit).committed }
            engine.append(character)
            return CompositionUpdate(committed: committed, marked: engine.text, handled: true)
        }
    }
}
