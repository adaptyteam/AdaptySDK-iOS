//
//  LegacyLocalizationResolverTests.swift
//  AdaptyTests
//

@testable import AdaptyUIBuilder
import Testing

@Suite("Legacy localization resolver", .tags(.logic))
struct LegacyLocalizationResolverTests {
    @Test("Matches the legacy selection algorithm", arguments: [
        (for: "ZH_Hant_TW", from: ["zh", "zh-hant", "zh-hant-tw"], default: nil, result: "zh-hant-tw"),
        (for: "ZH_Hant_TW", from: ["zh", "zh-hant"], default: nil, result: "zh-hant"),
        (for: "ZH_Hant_TW", from: ["zh"], default: nil, result: "zh"),
        (for: "en-US", from: ["en-us"], default: "fr", result: "en-us"),
        (for: "en-US", from: ["EN-US", "en"], default: nil, result: "en"),
        (for: "en-US", from: ["en_US"], default: nil, result: nil),
        (for: "en", from: ["en-us"], default: "fr", result: "fr"),
        (for: "de-DE", from: ["FR"], default: "FR", result: "FR"),
        (for: "de-DE", from: [], default: "FR_ca", result: "FR_ca"),
        (for: "de-DE", from: ["en"], default: nil, result: nil),
        (for: "de-DE", from: [], default: "", result: ""),
        (for: "en--US", from: ["en-us", "en-", "en"], default: nil, result: "en-"),
        (for: "en--US", from: ["en--us", "en-"], default: nil, result: "en--us"),
        (for: "en_", from: ["en", "en-"], default: nil, result: "en-"),
        (for: "-EN", from: ["en"], default: "fr", result: "fr"),
        (for: "-EN", from: [""], default: "fr", result: "fr"),
        (for: "-EN", from: [""], default: nil, result: nil),
        (for: "en-US", from: ["en", "en"], default: "en", result: "en"),
        (for: " en-US ", from: ["en-us", "en"], default: "fr", result: "fr"),
        (for: "", from: ["en"], default: nil, result: nil),
        (for: "", from: [""], default: "fr", result: "fr"),
    ] as [(for: LocaleId, from: [LocaleId], default: LocaleId?, result: LocaleId?)])
    func select(locale: LocaleId, locales: [LocaleId], defaultLocale: LocaleId?, expected: LocaleId?) throws {
        #expect(LegacyLocalizationResolver().resolve(
            for: locale,
            from: .init(locales: locales, defaultLocale: defaultLocale)
        ) == expected)
    }

    @Test("Backend examples from the specification", arguments: [
        (for: "pt-BR", from: ["en", "pt"], default: "en", result: "pt"),
        (for: "pt_BR", from: ["en", "pt-br"], default: "en", result: "pt-br"),
        (for: "PT-br", from: ["en", "pt-br"], default: "en", result: "pt-br"),
        (for: "zh_Hant_TW", from: ["en", "zh-hans", "zh-hant"], default: "en", result: "zh-hant"),
        (for: "zh-Hans-CN", from: ["en", "zh-hans", "zh-hant"], default: "en", result: "zh-hans"),
        (for: "zh-TW", from: ["en", "zh-hans", "zh-hant"], default: "en", result: "en"),
        (for: "zh_CN", from: ["en", "zh-hans", "zh-hant"], default: "en", result: "en"),
        (for: "ZH-hk", from: ["en", "zh-hk", "zh-hant"], default: "en", result: "zh-hk"),
        (for: "zh-HK", from: ["en", "zh-hant"], default: "en", result: "en"),
        (for: "es-MX", from: ["en", "es-419"], default: "en", result: "en"),
        (for: "es-MX", from: ["en", "es", "es-419"], default: "en", result: "es"),
        (for: "es_419", from: ["en", "es-419"], default: "en", result: "es-419"),
        (for: "pt", from: ["en", "pt-br"], default: "en", result: "en"),
        (for: "pt-PT", from: ["en", "pt", "pt-br"], default: "en", result: "pt"),
        (for: "pt-BR-", from: ["en", "pt-br"], default: "en", result: "pt-br"),
        (for: "pt BR", from: ["en", "pt-br"], default: "en", result: "en"),
        (for: "pt--BR", from: ["en", "pt-br"], default: "en", result: "en"),
        (for: "fr-CA", from: ["de", "fr"], default: "de", result: "fr"),
        (for: "it", from: ["de", "fr"], default: "de", result: "de"),
        (for: "en", from: ["pt-BR"], default: "pt-BR", result: "pt-BR"),
        (for: "pt-BR", from: ["en", "pt-BR"], default: "en", result: "en"),
        (for: "de", from: ["en", "fr-ca"], default: "fr-ca", result: "fr-ca"),
        (for: "de", from: ["en", "fr"], default: nil, result: nil),
        (for: "de", from: ["en", "fr"], default: "de", result: "de"),
        (for: "en", from: ["de", "fr"], default: "de", result: "de"),
        (for: "fil-PH", from: ["en", "fil"], default: "en", result: "fil"),
        (for: "yue-Hant-HK", from: ["en", "yue", "zh-hant"], default: "en", result: "yue"),
        (for: "sr-Latn-RS", from: ["en", "sr"], default: "en", result: "sr"),

        (for: "ru,en", from: ["en", "ru"], default: "en", result: "en"),
        (for: "en-US,ru", from: ["en", "en-us", "ru"], default: "en", result: "en"),
        (for: "ru-RU,en-US;q=0.9", from: ["en", "ru"], default: "en", result: "ru"),
        (for: "fr-CA, en", from: ["de", "fr"], default: "de", result: "fr"),
        (for: "pt-BR;q=1", from: ["en", "pt", "pt-br"], default: "en", result: "pt"),
        (for: "de en", from: ["en", "de"], default: "en", result: "en"),
        (for: "pt-BR", from: ["en", "pt", "pt-br"], default: "en", result: "pt-br"),
        (for: "pt-BR", from: ["en", "pt-br", "pt-BR"], default: "en", result: "pt-br"),
        (for: "de", from: ["en", "pt-br", "pt-BR"], default: "pt-BR", result: "pt-BR"),
        (for: "pt-BR", from: ["en", "pt-br", "pt-br"], default: "en", result: "pt-br"),
    ] as [(for: LocaleId, from: [LocaleId], default: LocaleId?, result: LocaleId?)])
    func backendExamples(locale: LocaleId, locales: [LocaleId], defaultLocale: LocaleId?, expected: LocaleId?) throws {
        #expect(LegacyLocalizationResolver().resolve(
            for: locale,
            from: .init(locales: locales, defaultLocale: defaultLocale)
        ) == expected)
    }

    @Test("Uses only the first preference", arguments: [
        (for: ["fr", "en"], from: ["en", "fr"], default: "en", result: "fr"),
        (for: ["de", "fr"], from: ["en", "fr"], default: "en", result: "en"),
        (for: [], from: ["en", "fr"], default: "fr", result: "fr"),
        (for: [], from: ["en", "fr"], default: nil, result: nil),
    ] as [(for: [String], from: [String], default: String?, result: String?)])
    func preferences(locales: [String], available: [String], defaultLocale: String?, expected: String?) throws {
        #expect(LegacyLocalizationResolver().resolve(
            for: locales,
            from: .init(locales: available, defaultLocale: defaultLocale)
        ) == expected)
    }

    @Test("Backend examples with ignoresCase", arguments: [
        (for: "pt-BR", from: ["en", "pt"], default: "en", result: "pt", backendResult: "pt"),
        (for: "pt_BR", from: ["en", "pt-br"], default: "en", result: "pt-br", backendResult: "pt-br"),
        (for: "PT-br", from: ["en", "pt-br"], default: "en", result: "pt-br", backendResult: "pt-br"),
        (for: "zh_Hant_TW", from: ["en", "zh-hans", "zh-hant"], default: "en", result: "zh-hant", backendResult: "zh-hant"),
        (for: "zh-Hans-CN", from: ["en", "zh-hans", "zh-hant"], default: "en", result: "zh-hans", backendResult: "zh-hans"),
        (for: "zh-TW", from: ["en", "zh-hans", "zh-hant"], default: "en", result: "en", backendResult: "en"),
        (for: "zh_CN", from: ["en", "zh-hans", "zh-hant"], default: "en", result: "en", backendResult: "en"),
        (for: "ZH-hk", from: ["en", "zh-hk", "zh-hant"], default: "en", result: "zh-hk", backendResult: "zh-hk"),
        (for: "zh-HK", from: ["en", "zh-hant"], default: "en", result: "en", backendResult: "en"),
        (for: "es-MX", from: ["en", "es-419"], default: "en", result: "en", backendResult: "en"),
        (for: "es-MX", from: ["en", "es", "es-419"], default: "en", result: "es", backendResult: "es"),
        (for: "es_419", from: ["en", "es-419"], default: "en", result: "es-419", backendResult: "es-419"),
        (for: "pt", from: ["en", "pt-br"], default: "en", result: "en", backendResult: "en"),
        (for: "pt-PT", from: ["en", "pt", "pt-br"], default: "en", result: "pt", backendResult: "pt"),
        (for: "pt-BR-", from: ["en", "pt-br"], default: "en", result: "pt-br", backendResult: "pt-br"),
        (for: "pt BR", from: ["en", "pt-br"], default: "en", result: "en", backendResult: "en"),
        (for: "pt--BR", from: ["en", "pt-br"], default: "en", result: "en", backendResult: "en"),
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
        (for: "sr-Latn-RS", from: ["en", "sr"], default: "en", result: "sr", backendResult: "sr"),

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

        // Ids in the list that are not lowercase or use underscores
        (for: "pt-BR", from: ["en", "pt_BR"], default: "en", result: "en", backendResult: "en"),
        (for: "pt_br", from: ["en", "pt_br"], default: "en", result: "en", backendResult: "en"),
        (for: "PT-BR", from: ["en", "PT-BR"], default: "en", result: "PT-BR", backendResult: "en"),
        (for: "ZH-HANT-TW", from: ["en", "zh-Hant"], default: "en", result: "zh-Hant", backendResult: "en"),
        (for: "en_US", from: ["en", "EN_us"], default: "fr", result: "en", backendResult: "en"),
    ] as [(for: LocaleId, from: [LocaleId], default: LocaleId?, result: LocaleId?, backendResult: LocaleId?)])
    func backendExamplesIgnoringCase(locale: LocaleId, locales: [LocaleId], defaultLocale: LocaleId?, expected: LocaleId?, backendResult _: LocaleId?) throws {
        #expect(LegacyLocalizationResolver(ignoresCase: true, replaceUnderscores: false).resolve(
            for: locale,
            from: .init(locales: locales, defaultLocale: defaultLocale)
        ) == expected)
    }

    @Test("Backend examples with replaceUnderscores", arguments: [
        (for: "pt-BR", from: ["en", "pt"], default: "en", result: "pt", backendResult: "pt"),
        (for: "pt_BR", from: ["en", "pt-br"], default: "en", result: "pt-br", backendResult: "pt-br"),
        (for: "PT-br", from: ["en", "pt-br"], default: "en", result: "pt-br", backendResult: "pt-br"),
        (for: "zh_Hant_TW", from: ["en", "zh-hans", "zh-hant"], default: "en", result: "zh-hant", backendResult: "zh-hant"),
        (for: "zh-Hans-CN", from: ["en", "zh-hans", "zh-hant"], default: "en", result: "zh-hans", backendResult: "zh-hans"),
        (for: "zh-TW", from: ["en", "zh-hans", "zh-hant"], default: "en", result: "en", backendResult: "en"),
        (for: "zh_CN", from: ["en", "zh-hans", "zh-hant"], default: "en", result: "en", backendResult: "en"),
        (for: "ZH-hk", from: ["en", "zh-hk", "zh-hant"], default: "en", result: "zh-hk", backendResult: "zh-hk"),
        (for: "zh-HK", from: ["en", "zh-hant"], default: "en", result: "en", backendResult: "en"),
        (for: "es-MX", from: ["en", "es-419"], default: "en", result: "en", backendResult: "en"),
        (for: "es-MX", from: ["en", "es", "es-419"], default: "en", result: "es", backendResult: "es"),
        (for: "es_419", from: ["en", "es-419"], default: "en", result: "es-419", backendResult: "es-419"),
        (for: "pt", from: ["en", "pt-br"], default: "en", result: "en", backendResult: "en"),
        (for: "pt-PT", from: ["en", "pt", "pt-br"], default: "en", result: "pt", backendResult: "pt"),
        (for: "pt-BR-", from: ["en", "pt-br"], default: "en", result: "pt-br", backendResult: "pt-br"),
        (for: "pt BR", from: ["en", "pt-br"], default: "en", result: "en", backendResult: "en"),
        (for: "pt--BR", from: ["en", "pt-br"], default: "en", result: "en", backendResult: "en"),
        (for: "fr-CA", from: ["de", "fr"], default: "de", result: "fr", backendResult: "fr"),
        (for: "it", from: ["de", "fr"], default: "de", result: "de", backendResult: "de"),
        (for: "en", from: ["pt-BR"], default: "pt-BR", result: "pt-BR", backendResult: "pt-BR"),
        (for: "pt-BR", from: ["en", "pt-BR"], default: "en", result: "en", backendResult: "en"),
        (for: "de", from: ["en", "fr-ca"], default: "fr-ca", result: "fr-ca", backendResult: "fr-ca"),
        (for: "de", from: ["en", "fr"], default: nil, result: nil, backendResult: nil),
        (for: "de", from: ["en", "fr"], default: "de", result: "de", backendResult: "de"),
        (for: "en", from: ["de", "fr"], default: "de", result: "de", backendResult: "de"),
        (for: "fil-PH", from: ["en", "fil"], default: "en", result: "fil", backendResult: "fil"),
        (for: "yue-Hant-HK", from: ["en", "yue", "zh-hant"], default: "en", result: "yue", backendResult: "yue"),
        (for: "sr-Latn-RS", from: ["en", "sr"], default: "en", result: "sr", backendResult: "sr"),

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

        // Ids in the list that are not lowercase or use underscores
        (for: "pt-BR", from: ["en", "pt_BR"], default: "en", result: "en", backendResult: "en"),
        (for: "pt_br", from: ["en", "pt_br"], default: "en", result: "pt_br", backendResult: "en"),
        (for: "PT-BR", from: ["en", "PT-BR"], default: "en", result: "en", backendResult: "en"),
        (for: "ZH-HANT-TW", from: ["en", "zh-Hant"], default: "en", result: "en", backendResult: "en"),
        (for: "en_US", from: ["en", "EN_us"], default: "fr", result: "en", backendResult: "en"),
    ] as [(for: LocaleId, from: [LocaleId], default: LocaleId?, result: LocaleId?, backendResult: LocaleId?)])
    func backendExamplesReplacingUnderscores(locale: LocaleId, locales: [LocaleId], defaultLocale: LocaleId?, expected: LocaleId?, backendResult _: LocaleId?) throws {
        #expect(LegacyLocalizationResolver(ignoresCase: false, replaceUnderscores: true).resolve(
            for: locale,
            from: .init(locales: locales, defaultLocale: defaultLocale)
        ) == expected)
    }

    @Test("Backend examples with ignoresCase and replaceUnderscores", arguments: [
        (for: "pt-BR", from: ["en", "pt"], default: "en", result: "pt", backendResult: "pt"),
        (for: "pt_BR", from: ["en", "pt-br"], default: "en", result: "pt-br", backendResult: "pt-br"),
        (for: "PT-br", from: ["en", "pt-br"], default: "en", result: "pt-br", backendResult: "pt-br"),
        (for: "zh_Hant_TW", from: ["en", "zh-hans", "zh-hant"], default: "en", result: "zh-hant", backendResult: "zh-hant"),
        (for: "zh-Hans-CN", from: ["en", "zh-hans", "zh-hant"], default: "en", result: "zh-hans", backendResult: "zh-hans"),
        (for: "zh-TW", from: ["en", "zh-hans", "zh-hant"], default: "en", result: "en", backendResult: "en"),
        (for: "zh_CN", from: ["en", "zh-hans", "zh-hant"], default: "en", result: "en", backendResult: "en"),
        (for: "ZH-hk", from: ["en", "zh-hk", "zh-hant"], default: "en", result: "zh-hk", backendResult: "zh-hk"),
        (for: "zh-HK", from: ["en", "zh-hant"], default: "en", result: "en", backendResult: "en"),
        (for: "es-MX", from: ["en", "es-419"], default: "en", result: "en", backendResult: "en"),
        (for: "es-MX", from: ["en", "es", "es-419"], default: "en", result: "es", backendResult: "es"),
        (for: "es_419", from: ["en", "es-419"], default: "en", result: "es-419", backendResult: "es-419"),
        (for: "pt", from: ["en", "pt-br"], default: "en", result: "en", backendResult: "en"),
        (for: "pt-PT", from: ["en", "pt", "pt-br"], default: "en", result: "pt", backendResult: "pt"),
        (for: "pt-BR-", from: ["en", "pt-br"], default: "en", result: "pt-br", backendResult: "pt-br"),
        (for: "pt BR", from: ["en", "pt-br"], default: "en", result: "en", backendResult: "en"),
        (for: "pt--BR", from: ["en", "pt-br"], default: "en", result: "en", backendResult: "en"),
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
        (for: "sr-Latn-RS", from: ["en", "sr"], default: "en", result: "sr", backendResult: "sr"),

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

        // Ids in the list that are not lowercase or use underscores
        (for: "pt-BR", from: ["en", "pt_BR"], default: "en", result: "pt_BR", backendResult: "en"),
        (for: "pt_br", from: ["en", "pt_br"], default: "en", result: "pt_br", backendResult: "en"),
        (for: "PT-BR", from: ["en", "PT-BR"], default: "en", result: "PT-BR", backendResult: "en"),
        (for: "ZH-HANT-TW", from: ["en", "zh-Hant"], default: "en", result: "zh-Hant", backendResult: "en"),
        (for: "en_US", from: ["en", "EN_us"], default: "fr", result: "EN_us", backendResult: "en"),
    ] as [(for: LocaleId, from: [LocaleId], default: LocaleId?, result: LocaleId?, backendResult: LocaleId?)])
    func backendExamplesIgnoringCaseAndReplacingUnderscores(locale: LocaleId, locales: [LocaleId], defaultLocale: LocaleId?, expected: LocaleId?, backendResult _: LocaleId?) throws {
        #expect(LegacyLocalizationResolver(ignoresCase: true, replaceUnderscores: true).resolve(
            for: locale,
            from: .init(locales: locales, defaultLocale: defaultLocale)
        ) == expected)
    }
}
