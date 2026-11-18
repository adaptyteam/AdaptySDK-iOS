//
//  SystemLocalizationResolverTests.swift
//  AdaptyTests
//

@testable import AdaptyUIBuilder
import Testing

@Suite("System localization resolver", .tags(.logic))
struct SystemLocalizationResolverTests {
    @Test("Uses Bundle.preferredLocalizations matching", arguments: [
        (for: "en", from: ["en", "de"], default: nil, result: "en"),
        (for: "en-GB", from: ["de", "en"], default: nil, result: "en"),
        (for: "en_GB", from: ["de", "en"], default: nil, result: "en"),
        (for: "pt-PT", from: ["en", "pt-BR"], default: "en", result: "pt-BR"),
        (for: "zh-TW", from: ["en", "zh-Hans", "zh-Hant"], default: "en", result: "zh-Hant"),
        (for: "zh-CN", from: ["en", "zh-Hans", "zh-Hant"], default: "en", result: "zh-Hans"),
        (for: "de", from: ["en", "fr"], default: "fr", result: "fr"),
        (for: "de", from: [], default: "fr", result: "fr"),
        (for: "de", from: [], default: nil, result: nil),

        // Synonym language codes: deprecated/macrolanguage code ↔ current code
        (for: "iw", from: ["en", "he"], default: nil, result: "he"),
        (for: "he", from: ["en", "iw"], default: nil, result: "iw"),
        (for: "tl", from: ["en", "fil"], default: nil, result: "fil"),
        (for: "fil-PH", from: ["en", "tl"], default: nil, result: "tl"),
        (for: "no", from: ["en", "nb"], default: nil, result: "nb"),
        (for: "nb-NO", from: ["en", "no"], default: nil, result: "no"),
    ] as [(for: String, from: [String], default: String?, result: String?)])
    func resolve(locale: String, locales: [String], defaultLocale: String?, expected: String?) {
        #expect(SystemLocalizationResolver().resolve(
            for: locale,
            from: .init(locales: locales, defaultLocale: defaultLocale)
        ) == expected)
    }


    @Test("Backend examples from the specification", arguments: [
        (for: "pt-BR", from: ["en", "pt"], default: "en", result: "pt", backendResult: "pt"),
        (for: "pt_BR", from: ["en", "pt-br"], default: "en", result: "pt-br", backendResult: "pt-br"),
        (for: "PT-br", from: ["en", "pt-br"], default: "en", result: "pt-br", backendResult: "pt-br"),
        (for: "zh_Hant_TW", from: ["en", "zh-hans", "zh-hant"], default: "en", result: "zh-hant", backendResult: "zh-hant"),
        (for: "zh-Hans-CN", from: ["en", "zh-hans", "zh-hant"], default: "en", result: "zh-hans", backendResult: "zh-hans"),
        (for: "zh-TW", from: ["en", "zh-hans", "zh-hant"], default: "en", result: "zh-hant", backendResult: "en"),
        (for: "zh_CN", from: ["en", "zh-hans", "zh-hant"], default: "en", result: "zh-hans", backendResult: "en"),
        (for: "ZH-hk", from: ["en", "zh-hk", "zh-hant"], default: "en", result: "zh-hk", backendResult: "zh-hk"),
        (for: "zh-HK", from: ["en", "zh-hant"], default: "en", result: "zh-hant", backendResult: "en"),
        (for: "es-MX", from: ["en", "es-419"], default: "en", result: "es-419", backendResult: "en"),
        (for: "es-MX", from: ["en", "es", "es-419"], default: "en", result: "es-419", backendResult: "es"),
        (for: "es_419", from: ["en", "es-419"], default: "en", result: "es-419", backendResult: "es-419"),
        (for: "pt", from: ["en", "pt-br"], default: "en", result: "pt-br", backendResult: "en"),
        (for: "pt-PT", from: ["en", "pt", "pt-br"], default: "en", result: "pt", backendResult: "pt"),
        (for: "pt-BR-", from: ["en", "pt-br"], default: "en", result: "pt-br", backendResult: "pt-br"),
        (for: "pt BR", from: ["en", "pt-br"], default: "en", result: "en", backendResult: "en"),
        (for: "pt--BR", from: ["en", "pt-br"], default: "en", result: "pt-br", backendResult: "en"),
        (for: "fr-CA", from: ["de", "fr"], default: "de", result: "fr", backendResult: "fr"),
        (for: "it", from: ["de", "fr"], default: "de", result: "de", backendResult: "de"),
        (for: "en", from: ["pt-BR"], default: "pt-BR", result: "pt-BR", backendResult: "pt-BR"),
        (for: "pt-BR", from: ["en", "pt-BR"], default: "en", result: "pt-BR", backendResult: "en"),
        (for: "de", from: ["en", "fr-ca"], default: "fr-ca", result: "fr-ca", backendResult: "fr-ca"),
        (for: "de", from: ["en", "fr"], default: nil, result: nil, backendResult: nil),
        (for: "de", from: ["en", "fr"], default: "de", result: "de", backendResult: "de"),
        (for: "en", from: ["de", "fr"], default: "de", result: "de", backendResult: "de"),
        (for: "fil-PH", from: ["en", "fil"], default: "en", result: "fil", backendResult: "fil"),
        (for: "yue-Hant-HK", from: ["en", "yue", "zh-hant"], default: "en", result: "yue", backendResult: "yue"),
        (for: "sr-Latn-RS", from: ["en", "sr"], default: "en", result: "en", backendResult: "sr"),

        (for: "ru,en", from: ["en", "ru"], default: "en", result: "en", backendResult: "en"),
        (for: "en-US,ru", from: ["en", "en-us", "ru"], default: "en", result: "en", backendResult: "en"),
        (for: "ru-RU,en-US;q=0.9", from: ["en", "ru"], default: "en", result: "ru", backendResult: "ru"),
        (for: "fr-CA, en", from: ["de", "fr"], default: "de", result: "fr", backendResult: "fr"),
        (for: "pt-BR;q=1", from: ["en", "pt", "pt-br"], default: "en", result: "pt", backendResult: "pt"),
        (for: "de en", from: ["en", "de"], default: "en", result: "en", backendResult: "en"),
        (for: "pt-BR", from: ["en", "pt", "pt-br"], default: "en", result: "pt-br", backendResult: "pt-br"),
        (for: "pt-BR", from: ["en", "pt-br", "pt-BR"], default: "en", result: "pt-br", backendResult: "pt-br"),
        (for: "de", from: ["en", "pt-br", "pt-BR"], default: "pt-BR", result: "pt-BR", backendResult: "pt-BR"),
        (for: "pt-BR", from: ["en", "pt-br", "pt-br"], default: "en", result: "pt-br", backendResult: "pt-br"),
    ] as [(for: LocaleId, from: [LocaleId], default: LocaleId?, result: LocaleId?, backendResult: LocaleId?)])
    func backendExamples(locale: LocaleId, locales: [LocaleId], defaultLocale: LocaleId?, expected: LocaleId?, backendResult: LocaleId?) {
        let isSameResult = expected == backendResult
        #expect(SystemLocalizationResolver().resolve(
            for: locale,
            from: .init(locales: locales, defaultLocale: defaultLocale)
        ) == expected)
    }

    @Test("Picks the first matching preference", arguments: [
        (for: ["de", "fr"], from: ["en", "fr"], default: "en", result: "fr"),
        (for: ["fr", "en"], from: ["en", "fr"], default: "en", result: "fr"),
        (for: ["de", "en-GB"], from: ["fr", "en"], default: "fr", result: "en"),
        (for: ["de", "it"], from: ["en", "fr"], default: "fr", result: "fr"),
        (for: [], from: ["en", "fr"], default: "fr", result: "fr"),
        (for: [], from: ["en", "fr"], default: nil, result: nil),
    ] as [(for: [String], from: [String], default: String?, result: String?)])
    func preferences(locales: [String], available: [String], defaultLocale: String?, expected: String?) {
        #expect(SystemLocalizationResolver().resolve(
            for: locales,
            from: .init(locales: available, defaultLocale: defaultLocale)
        ) == expected)
    }
}
