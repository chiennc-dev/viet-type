import XCTest
@testable import VietTypeCore

final class TypingEngineTests: XCTestCase {
    private func type(_ input: String, mode: InputMode = .telex) -> TypingEngine {
        var engine = TypingEngine(mode: mode)
        input.forEach { engine.append($0) }
        return engine
    }

    func testTelexWords() {
        let examples = [
            "tieengs": "tiếng", "Vieetj": "Việt", "ddawngj": "đặng",
            "dduwowngf": "đường", "dduowngf": "đường", "tuws": "tứ",
            "nguowif": "người", "nguoiwf": "người", "nghieengs": "nghiếng", "chuyeenj": "chuyện",
            "quas": "quá", "quys": "quý", "quowr": "quở", "gias": "giá",
            "gif": "gì", "gieengs": "giếng", "hoaf": "hòa", "khoer": "khỏe",
            "thuys": "thúy", "hoangf": "hoàng", "tuyeens": "tuyến",
            "khuyur": "khuỷu", "ngoaif": "ngoài", "muoons": "muốn",
            "aas": "ấ", "aws": "ắ", "ees": "ế", "oos": "ố", "ows": "ớ",
            "DDUOWNGF": "ĐƯỜNG", "TIEENGS": "TIẾNG", "VIEETJ": "VIỆT",
            "asw": "ắ", "ase": "áe", "huuwx": "hữu", "ruouwj": "rượu",
            "huwux": "hữu", "ruwowuj": "rượu", "huuww": "huuw", "ruouww": "ruouw"
        ]
        for (input, expected) in examples {
            XCTAssertEqual(type(input).text, expected, input)
        }
    }

    func testVNIWords() {
        let examples = [
            "tie6ng1": "tiếng", "Vie6t5": "Việt", "d9a8ng5": "đặng",
            "d9uo7ng2": "đường", "d9u7o7ng2": "đường", "nguoi72": "người",
            "qua1": "quá", "gia1": "giá", "gi2": "gì", "hoa2": "hòa",
            "khoe3": "khỏe", "thuy1": "thúy", "hoa2ng": "hoàng",
            "chuye6n5": "chuyện", "muoi61": "muối", "D9UO7NG2": "ĐƯỜNG", "a16": "ấ",
            "a18": "ắ", "o17": "ớ", "123": "123", "abc9": "abc9",
            "huu74": "hữu", "ruou75": "rượu", "huu77": "huu7", "ruou77": "ruou7",
            "duong972": "đường", "dau965": "đậu", "dung975": "đựng"
        ]
        for (input, expected) in examples {
            XCTAssertEqual(type(input, mode: .vni).text, expected, input)
        }
    }

    func testEveryVowelAndToneInBothCasesAndModes() {
        let vowels = [
            ("a", "a", "aáàảãạ"), ("aw", "a8", "ăắằẳẵặ"),
            ("aa", "a6", "âấầẩẫậ"), ("e", "e", "eéèẻẽẹ"),
            ("ee", "e6", "êếềểễệ"), ("i", "i", "iíìỉĩị"),
            ("o", "o", "oóòỏõọ"), ("oo", "o6", "ôốồổỗộ"),
            ("ow", "o7", "ơớờởỡợ"), ("u", "u", "uúùủũụ"),
            ("uw", "u7", "ưứừửữự"), ("y", "y", "yýỳỷỹỵ")
        ]
        for (telex, vni, row) in vowels {
            for (index, expected) in row.enumerated() {
                let t = telex + ["", "s", "f", "r", "x", "j"][index]
                let v = vni + ["", "1", "2", "3", "4", "5"][index]
                XCTAssertEqual(type(t).text, String(expected), t)
                XCTAssertEqual(type(v, mode: .vni).text, String(expected), v)
                XCTAssertEqual(type(t.uppercased()).text, String(expected).uppercased(), t)
                XCTAssertEqual(type(v.uppercased(), mode: .vni).text, String(expected).uppercased(), v)
            }
        }
    }

    func testRepeatedModifiersAndToneRemoval() {
        for (input, expected) in ["aaa": "aa", "eee": "ee", "ooo": "oo", "ddd": "dd",
                                  "aww": "aw", "uww": "uw", "oww": "ow", "ass": "as",
                                  "asf": "à", "asz": "a", "aszs": "á", "uoww": "uow"] {
            XCTAssertEqual(type(input).text, expected, input)
        }
        for (input, expected) in ["a66": "a6", "a88": "a8", "o77": "o7", "d99": "d9",
                                  "a11": "a1", "a10": "a", "a12": "à", "uo77": "uo7"] {
            XCTAssertEqual(type(input, mode: .vni).text, expected, input)
        }
    }

    func testToneMovesAsWordDevelops() {
        var engine = type("hoas")
        XCTAssertEqual(engine.text, "hóa")
        engine.append("n")
        XCTAssertEqual(engine.text, "hoán")
        engine.backspace()
        XCTAssertEqual(engine.text, "hóa")
    }

    func testBackspaceDeletesVisibleCharacterAndTone() {
        var engine = type("aws")
        XCTAssertEqual(engine.text, "ắ")
        engine.backspace()
        XCTAssertTrue(engine.isEmpty)
        XCTAssertEqual(engine.text, "")
        engine.backspace()
        engine.append("b")
        XCTAssertEqual(engine.text, "b")
        engine = type("tieengs")
        engine.backspace()
        XCTAssertEqual(engine.text, "tiến")
        engine.backspace()
        XCTAssertEqual(engine.text, "tiế")
        engine.backspace()
        XCTAssertEqual(engine.text, "ti")
    }

    func testResetAndIndependentSessions() {
        var first = type("Vieetj")
        let second = type("nam")
        XCTAssertEqual(first.rawInput, "Vieetj")
        XCTAssertEqual(second.text, "nam")
        first.reset()
        XCTAssertEqual(first.rawInput, "")
        XCTAssertTrue(first.isEmpty)
        first.append("s")
        XCTAssertEqual(first.text, "s")
    }

    func testNormalizedUnicode() {
        for mode in InputMode.allCases {
            let engine = type(mode == .telex ? "DDUOWNGF" : "D9UO7NG2", mode: mode)
            XCTAssertEqual(engine.text, engine.text.precomposedStringWithCanonicalMapping)
            XCTAssertEqual(engine.text.count, 5)
        }
    }
}
