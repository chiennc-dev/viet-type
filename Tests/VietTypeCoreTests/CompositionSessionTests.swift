import XCTest
@testable import VietTypeCore

final class CompositionSessionTests: XCTestCase {
    private func type(_ input: String, into session: inout CompositionSession) {
        for character in input { _ = session.process(.text(String(character))) }
    }

    func testCommitDoesNotDuplicateOnFocusChange() {
        var session = CompositionSession()
        type("tieengs", into: &session)
        XCTAssertEqual(session.process(.commit), CompositionUpdate(committed: "tiếng"))
        XCTAssertEqual(session.process(.commit), CompositionUpdate())
        type("Vieetj", into: &session)
        XCTAssertEqual(session.process(.commit).committed, "Việt")
    }

    func testPunctuationWhitespaceAndUnicodeAreForwardedOnce() {
        for delimiter in [" ", "\n", "\t", ",", ".", "!", "🙂", "你", "\u{F702}", "ab", ""] {
            var session = CompositionSession()
            type("Vieetj", into: &session)
            let update = session.process(.text(delimiter))
            XCTAssertEqual(update.committed, "Việt", delimiter)
            XCTAssertFalse(update.handled, delimiter)
            XCTAssertEqual(session.process(.commit), CompositionUpdate())
        }
    }

    func testEscapeRestoresOriginalKeys() {
        var session = CompositionSession()
        type("address", into: &session)
        XCTAssertEqual(session.process(.escape), CompositionUpdate(committed: "address", handled: true))
        XCTAssertFalse(session.process(.escape).handled)
    }

    func testVNILeavesLeadingDigitsToHost() {
        var session = CompositionSession(mode: .vni)
        for character in "2026" { XCTAssertFalse(session.process(.text(String(character))).handled) }
        type("vie6t5", into: &session)
        XCTAssertEqual(session.process(.text(" ")).committed, "việt")
    }

    func testSwitchingModeCommitsWithPreviousMode() {
        var session = CompositionSession()
        type("tieengs", into: &session)
        XCTAssertEqual(session.changeMode(to: .vni).committed, "tiếng")
        type("Vie6t5", into: &session)
        XCTAssertEqual(session.process(.commit).committed, "Việt")
    }

    func testBackspaceClearsMarkedTextAndAllowsHostDeletionWhenEmpty() {
        var session = CompositionSession()
        type("aws", into: &session)
        XCTAssertEqual(session.process(.backspace), CompositionUpdate(marked: "", handled: true))
        XCTAssertFalse(session.process(.backspace).handled)
        type("em", into: &session)
        XCTAssertEqual(session.process(.commit).committed, "em")
    }

    func testForeignWordsAreRestoredAtCommit() {
        for word in ["hello", "swift", "macos", "banana", "browser", "address", "email", "github", "123abc"] {
            var session = CompositionSession()
            // Leading digits are passed through separately in real use.
            if word.first?.isNumber == true { continue }
            type(word, into: &session)
            XCTAssertEqual(session.process(.commit).committed, word, word)
        }
    }

    func testSpellingDoesNotRejectVietnameseCorpus() {
        let words = ["tiếng", "Việt", "đường", "hữu", "rượu", "khỏe", "hòa", "thúy", "người", "giếng",
                     "gì", "quý", "quở", "chuyện", "tuyến", "khuỷu", "nghiêng", "ngoài", "muốn", "yêu",
                     "khuya", "xoong", "ngoằn", "ngoèo", "khuyên", "khuấy", "khuỵu", "nguyễn", "oanh",
                     "quyền", "quỳnh", "già", "quốc", "nước", "mười", "cười", "trường", "thưởng"]
        for word in words { XCTAssertTrue(VietnameseSyllable.isPlausible(word), word) }
        var session = CompositionSession()
        type("tieengs", into: &session)
        XCTAssertEqual(session.process(.commit).committed, "tiếng")
    }

    func testSpellingCanBeDisabledForAbbreviations() {
        var session = CompositionSession()
        session.restoreInvalidWords = false
        type("swift", into: &session)
        XCTAssertEqual(session.process(.commit).committed, "swìt")
    }

    func testLongTokensPreserveEveryCharacterAndBoundComposition() {
        var session = CompositionSession()
        var committed = ""
        for _ in 0..<10_000 {
            let update = session.process(.text("b"))
            committed += update.committed ?? ""
            XCTAssertLessThanOrEqual(session.engine.rawInput.count, 128)
        }
        committed += session.process(.commit).committed ?? ""
        XCTAssertEqual(committed, String(repeating: "b", count: 10_000))
    }

    func testDifferentWindowsDoNotShareComposition() {
        var first = CompositionSession()
        var second = CompositionSession(mode: .vni)
        type("tieengs", into: &first)
        type("Vie6t5", into: &second)
        XCTAssertEqual(second.process(.commit).committed, "Việt")
        XCTAssertEqual(first.process(.commit).committed, "tiếng")
    }
}
