import Foundation

/// Conservative spelling checks used only when committing a word. Ambiguous
/// English words ("as" → "á") still require Escape or an English Input Source.
enum VietnameseSyllable {
    private static let initials = ["ngh", "ch", "gh", "gi", "kh", "ng", "nh", "ph", "qu", "th", "tr",
                                   "b", "c", "d", "đ", "g", "h", "k", "l", "m", "n", "p", "r", "s", "t", "v", "x", ""]
    private static let finals: Set<String> = ["", "c", "ch", "m", "n", "ng", "nh", "p", "t"]
    private static let nuclei: Set<String> = [
        "a", "ai", "ao", "au", "ay", "ă", "â", "âu", "ây", "e", "eo", "ê", "êu",
        "i", "ia", "iê", "iêu", "iu", "o", "oa", "oai", "oao", "oay", "oă", "oe", "oeo", "oi", "oo",
        "ô", "ôi", "ơ", "ơi", "u", "ua", "uai", "uay", "uă", "uâ", "uây", "uê", "uêu", "ui", "uô", "uôi",
        "uơ", "uy", "uya", "uyê", "uyu", "ư", "ưa", "ưi", "ưu", "ươ", "ươi", "ươu", "y", "yê", "yêu"
    ]
    private static let vowels = Set("aăâeêioôơuưy")
    private static let toneMarks = Set<Unicode.Scalar>(["\u{0300}", "\u{0301}", "\u{0303}", "\u{0309}", "\u{0323}"])

    static func isPlausible(_ word: String) -> Bool {
        let decomposed = word.lowercased().decomposedStringWithCanonicalMapping
        let plain = String(String.UnicodeScalarView(decomposed.unicodeScalars.filter { !toneMarks.contains($0) }))
            .precomposedStringWithCanonicalMapping
        for initial in initials where plain.hasPrefix(initial) {
            let rest = plain.dropFirst(initial.count)
            let nucleus = rest.prefix { vowels.contains($0) }
            let ending = String(rest.dropFirst(nucleus.count))
            if nuclei.contains(String(nucleus)), finals.contains(ending) { return true }
        }
        return false
    }
}
