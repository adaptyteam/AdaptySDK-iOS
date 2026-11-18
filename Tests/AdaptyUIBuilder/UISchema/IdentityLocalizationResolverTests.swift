//
//  IdentityLocalizationResolverTests.swift
//  AdaptyTests
//

@testable import AdaptyUIBuilder
import Testing

@Suite("Identity localization resolver", .tags(.logic))
struct IdentityLocalizationResolverTests {
    @Test("Returns the requested locale unchanged", arguments: [
        (for: "en-US", from: ["en"], default: "fr"),
        (for: "zh_Hant_TW", from: [], default: nil),
        (for: "", from: ["en"], default: "en"),
    ] as [(for: String, from: [String], default: String?)])
    func resolve(locale: String, locales: [String], defaultLocale: String?) {
        #expect(IdentityLocalizationResolver().resolve(
            for: locale,
            from: .init(locales: locales, defaultLocale: defaultLocale)
        ) == locale)
    }
}
