//
//  Base64URLEncodedTests.swift
//  AdaptyTests
//

@testable import Adapty
import Testing

@Suite("Flow locale path segment", .tags(.logic))
struct Base64URLEncodedTests {
    @Test("Locale is base64url of UTF-8 bytes without padding", arguments: [
        (locale: "en", encoded: "ZW4"), // "ZW4=": padding dropped
        (locale: "zh-hans", encoded: "emgtaGFucw"), // "emgtaGFucw=="
        (locale: "pt_BR", encoded: "cHRfQlI"), // spelling kept, no normalization
        (locale: "ja?", encoded: "amE_"), // "amE/": "/" would split the path
        (locale: "en~", encoded: "ZW5-"), // "ZW5+"
        (locale: "дом", encoded: "0LTQvtC8"), // non-ASCII goes as UTF-8
    ])
    func encode(locale: String, encoded: String) {
        #expect(locale.base64URLEncoded == encoded)
    }
}
