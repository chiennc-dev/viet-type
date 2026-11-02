import Foundation

public enum InputMode: String, CaseIterable {
    case telex, vni
    public var title: String { self == .telex ? "Telex" : "VNI" }
}

/// A word-scoped Unicode composition engine, independent of AppKit.
public struct TypingEngine {
    public private(set) var mode: InputMode
    public private(set) var rawInput = ""
    private var letters: [Character] = []
    private var tone: Int = 0

    // Columns: ngang, sắc, huyền, hỏi, ngã, nặng.
    private static let rows = [
        "aáàảãạ", "ăắằẳẵặ", "âấầẩẫậ", "eéèẻẽẹ", "êếềểễệ",
        "iíìỉĩị", "oóòỏõọ", "ôốồổỗộ", "ơớờởỡợ", "uúùủũụ",
        "ưứừửữự", "yýỳỷỹỵ"
    ].map(Array.init)

    public init(mode: InputMode = .telex) { self.mode = mode }

    public mutating func changeMode(to mode: InputMode) {
        reset()
        self.mode = mode
    }

    /// Structural validation, not a dictionary or language detector.
    public func committedText(restoreInvalidWords: Bool = true) -> String {
        restoreInvalidWords && !VietnameseSyllable.isPlausible(text) ? rawInput : text
    }

    public var isEmpty: Bool { letters.isEmpty }

    public var text: String {
        var result = letters
        if tone != 0, let index = toneIndex,
           let row = Self.rows.first(where: { $0[0] == lower(result[index]) }) {
            result[index] = matchingCase(row[tone], to: result[index])
        }
        return String(result).precomposedStringWithCanonicalMapping
    }

    public mutating func reset() {
        letters.removeAll(keepingCapacity: true)
        rawInput = ""
        tone = 0
    }

    /// Deletes one visible character, including its diacritics.
    public mutating func backspace() {
        guard !letters.isEmpty else { return }
        let oldToneIndex = toneIndex
        let removed = letters.count - 1
        letters.removeLast()
        if oldToneIndex == removed || toneIndex == nil { tone = 0 }
        // After editing, Escape restores this edited spelling.
        rawInput = text
    }

    public mutating func append(_ character: Character) {
        rawInput.append(character)
        let key = lower(character)
        let tones: [Character: Int] = mode == .telex
            ? ["s": 1, "f": 2, "r": 3, "x": 4, "j": 5]
            : ["1": 1, "2": 2, "3": 3, "4": 4, "5": 5]
        if let nextTone = tones[key], toneIndex != nil {
            if tone == nextTone {
                tone = 0
                letters.append(character)
            } else {
                tone = nextTone
            }
            return
        }
        if (mode == .telex && key == "z") || (mode == .vni && key == "0") {
            if tone != 0 { tone = 0; return }
        }
        if mode == .telex {
            if key == "d", transformD(character) { return }
            if [Character("a"), "e", "o"].contains(key), circumflex(key, typed: character) { return }
            if key == "w", hornOrBreve(typed: character) { return }
        } else {
            if key == "9", transformD(character) { return }
            if key == "6", circumflex(nil, typed: character) { return }
            if key == "7", hornOrBreve(typed: character, allowBreve: false) { return }
            if key == "8", breve(character) { return }
        }
        letters.append(character)
    }

    private mutating func transformD(_ typed: Character) -> Bool {
        guard let index = letters.indices.last(where: { ["d", "đ"].contains(lower(letters[$0])) }),
              (index == letters.count - 1 || mode == .vni) else { return false }
        let wasModified = lower(letters[index]) == "đ"
        letters[index] = matchingCase(wasModified ? "d" : "đ", to: letters[index])
        if wasModified { letters.append(typed) }
        return true
    }

    private mutating func circumflex(_ required: Character?, typed: Character) -> Bool {
        let pairs: [Character: Character] = ["a": "â", "e": "ê", "o": "ô"]
        guard let index = vowelIndices.last(where: {
            let vowel = lower(letters[$0])
            if let required { return vowel == required || pairs[required] == vowel }
            return pairs[vowel] != nil || pairs.values.contains(vowel)
        }) else { return false }
        let current = lower(letters[index])
        if let required, current != required && pairs[required] != current { return false }
        if let transformed = pairs[current] {
            letters[index] = matchingCase(transformed, to: letters[index])
            return true
        }
        if let pair = pairs.first(where: { $0.value == current }) {
            letters[index] = matchingCase(pair.key, to: letters[index])
            letters.append(typed)
            return true
        }
        return false
    }

    private mutating func breve(_ typed: Character) -> Bool {
        guard let index = vowelIndices.last else { return false }
        let current = lower(letters[index])
        guard current == "a" || current == "ă" else { return false }
        letters[index] = matchingCase(current == "a" ? "ă" : "a", to: letters[index])
        if current == "ă" { letters.append(typed) }
        return true
    }

    private mutating func hornOrBreve(typed: Character, allowBreve: Bool = true) -> Bool {
        let vowels = vowelIndices
        let eligible: [Character] = allowBreve ? ["a", "ă", "u", "ư", "o", "ơ"] : ["u", "ư", "o", "ơ"]
        // Late horn entry: huu+w → hưu, ruou+w → rươu.
        if vowels.count >= 2 {
            let last = vowels[vowels.count - 1]
            let previous = vowels[vowels.count - 2]
            if lower(letters[last]) == "u", previous + 1 == last {
                if ["u", "ư"].contains(lower(letters[previous])) {
                    let undo = lower(letters[previous]) == "ư"
                    letters[previous] = matchingCase(undo ? "u" : "ư", to: letters[previous])
                    if undo { letters.append(typed) }
                    return true
                }
                if vowels.count >= 3 {
                    let first = vowels[vowels.count - 3]
                    if first + 1 == previous, ["u", "ư"].contains(lower(letters[first])),
                       ["o", "ơ"].contains(lower(letters[previous])) {
                        let undo = lower(letters[first]) == "ư" && lower(letters[previous]) == "ơ"
                        letters[first] = matchingCase(undo ? "u" : "ư", to: letters[first])
                        letters[previous] = matchingCase(undo ? "o" : "ơ", to: letters[previous])
                        if undo { letters.append(typed) }
                        return true
                    }
                }
            }
        }
        guard let index = vowels.last(where: { eligible.contains(lower(letters[$0])) }) else { return false }
        let current = lower(letters[index])
        if allowBreve && (current == "a" || current == "ă") { return breve(typed) }
        let pairs: [Character: Character] = ["u": "ư", "o": "ơ"]
        // uo + w / 7 changes both vowels. Exclude the u in qu.
        if let position = vowels.firstIndex(of: index), position > 0 {
            let previous = vowels[position - 1]
            if previous + 1 == index,
               ["u", "ư"].contains(lower(letters[previous])),
               ["o", "ơ"].contains(current) {
                let undo = lower(letters[previous]) == "ư" && current == "ơ"
                letters[previous] = matchingCase(undo ? "u" : "ư", to: letters[previous])
                letters[index] = matchingCase(undo ? "o" : "ơ", to: letters[index])
                if undo { letters.append(typed) }
                return true
            }
        }
        if let transformed = pairs[current] {
            letters[index] = matchingCase(transformed, to: letters[index])
            return true
        }
        if let pair = pairs.first(where: { $0.value == current }) {
            letters[index] = matchingCase(pair.key, to: letters[index])
            letters.append(typed)
            return true
        }
        return false
    }

    private var vowelIndices: [Int] {
        var indices = letters.indices.filter { isVowel(letters[$0]) }
        // u in qu and i in gi are semivowels only if another vowel follows.
        if indices.count > 1, let first = indices.first, first > 0 {
            let pair = String([lower(letters[first - 1]), lower(letters[first])])
            if pair == "qu" || pair == "gi" { indices.removeFirst() }
        }
        return indices
    }

    private var toneIndex: Int? {
        let vowels = vowelIndices
        guard let last = vowels.last else { return nil }
        // ê / ơ carry the tone in iê, uê, uơ, ươ, uyê, etc.
        if let preferred = vowels.last(where: { ["ê", "ơ"].contains(lower(letters[$0])) }) {
            return preferred
        }
        if vowels.count == 1 { return last }
        if vowels.count >= 3 { return vowels[vowels.count - 2] }
        // Traditional spelling: hòa, khỏe, thúy; closed syllables: hoàng, tuyến.
        return last == letters.count - 1 ? vowels[0] : last
    }

    private func isVowel(_ character: Character) -> Bool {
        Self.rows.contains { $0[0] == lower(character) }
    }

    private func lower(_ character: Character) -> Character {
        Character(String(character).lowercased())
    }

    private func matchingCase(_ character: Character, to original: Character) -> Character {
        String(original) == String(original).uppercased()
            ? Character(String(character).uppercased()) : character
    }
}
