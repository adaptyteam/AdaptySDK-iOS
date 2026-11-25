//
//  LocalizationStrategyTests.swift
//  AdaptyTests
//

@testable import AdaptyUIBuilder
import Testing

@Suite("Localization strategy", .tags(.logic))
struct LocalizationStrategyTests {
    @Test("Custom resolver goes first, nil falls back to the built-in resolver", arguments: [
        (custom: "fr", fallback: .auto, preferences: ["de"], result: "fr"),
        // an id the schema does not have is ignored, the built-in resolver decides
        (custom: "xx", fallback: .auto, preferences: ["fr"], result: "fr"),
        (custom: "xx", fallback: .legacy, preferences: ["de"], result: "en"),
        (custom: nil, fallback: .auto, preferences: ["de", "fr"], result: "fr"),
        (custom: nil, fallback: .system, preferences: ["de", "fr"], result: "fr"),
        // legacy looks only at the first preference
        (custom: nil, fallback: .legacy, preferences: ["de", "fr"], result: "en"),
        (custom: nil, fallback: .auto, preferences: ["de"], result: "en"),
    ] as [(custom: String?, fallback: AdaptyUILocalizationResolver, preferences: [String], result: String?)])
    func customThenFallback(custom: String?, fallback: AdaptyUILocalizationResolver, preferences: [String], expected: String?) async throws {
        let strategy = AdaptyUILocalizationStrategy.custom(resolver: FixedResolver(result: custom), fallbackResolver: fallback)
        #expect(try await strategy.resolve(for: preferences, from: Self.schema(defaultLocale: "en")) == expected)
    }

    @Test("Built-in strategies without a custom resolver", arguments: [
        (strategy: .auto, preferences: ["de", "fr"], result: "fr"),
        (strategy: .system, preferences: ["de", "fr"], result: "fr"),
        (strategy: .legacy, preferences: ["de", "fr"], result: "en"),
        (strategy: .auto, preferences: [], result: "en"),
    ] as [(strategy: AdaptyUILocalizationStrategy, preferences: [String], result: String?)])
    func builtIn(strategy: AdaptyUILocalizationStrategy, preferences: [String], expected: String?) async throws {
        #expect(try await strategy.resolve(for: preferences, from: Self.schema(defaultLocale: "en")) == expected)
    }

    @Test("No match and no default locale falls back to \"en\" only when the source has exactly \"en\"", arguments: [
        (locales: ["en", "fr"], default: nil, custom: nil, result: "en"),
        (locales: ["fr", "de"], default: nil, custom: nil, result: nil),
        // an id the source does not have is ignored
        (locales: ["fr", "de"], default: nil, custom: "xx", result: nil),
        (locales: ["en", "fr"], default: nil, custom: "xx", result: "en"),
        // exact match only: no case folding, no prefix match
        (locales: ["fr", "EN"], default: nil, custom: nil, result: nil),
        (locales: ["fr", "en-US"], default: nil, custom: nil, result: nil),
        // a default locale wins over "en"
        (locales: ["fr", "de"], default: "de", custom: nil, result: "de"),
    ] as [(locales: [String], default: String?, custom: String?, result: String?)], [AdaptyUILocalizationResolver.system, .legacy])
    func globalDefault(
        _ example: (locales: [String], default: String?, custom: String?, result: String?),
        fallback: AdaptyUILocalizationResolver
    ) async {
        let source = AdaptyUILocalizationSource(locales: example.locales, defaultLocale: example.default)
        let strategy = AdaptyUILocalizationStrategy.custom(resolver: FixedResolver(result: example.custom), fallbackResolver: fallback)
        #expect(await strategy.resolve(for: ["ja"], from: source, isLegacyVersion: false) == example.result)
    }

    @Test("No choice skips every resolver, including the custom one", arguments: [
        (locales: ["fr"], default: nil, hasChoice: false, result: "fr"),
        (locales: ["fr"], default: "fr", hasChoice: false, result: "fr"),
        (locales: [], default: "fr", hasChoice: false, result: "fr"),
        (locales: ["fr", "fr"], default: nil, hasChoice: false, result: "fr"),
        (locales: [], default: nil, hasChoice: false, result: nil),
        // with a choice the custom resolver is asked, and its available answer wins over the default
        (locales: ["fr"], default: "en", hasChoice: true, result: "fr"),
        (locales: ["en", "fr"], default: nil, hasChoice: true, result: "fr"),
    ] as [(locales: [String], default: String?, hasChoice: Bool, result: String?)])
    func noChoice(locales: [String], defaultLocale: String?, hasChoice: Bool, expected: String?) async throws {
        let source = AdaptyUILocalizationSource(locales: locales, defaultLocale: defaultLocale)
        #expect(source.hasChoice == hasChoice)
        let resolver = CountingResolver(result: "fr")
        let strategy = AdaptyUILocalizationStrategy.custom(resolver: resolver)
        #expect(await strategy.resolve(for: ["de"], from: source, isLegacyVersion: false) == expected)
        #expect(await resolver.calls.value == (hasChoice ? 1 : 0))
    }
}

private struct CountingResolver: AdaptyUICustomLocalizationResolver {
    let result: String?
    let calls = Counter()

    func resolve(for _: [String], from _: AdaptyUILocalizationSource) async -> String? {
        await calls.increment()
        return result
    }
}

private actor Counter {
    private(set) var value = 0

    func increment() {
        value += 1
    }
}

private struct FixedResolver: AdaptyUICustomLocalizationResolver {
    let result: String?

    func resolve(for _: [String], from _: AdaptyUILocalizationSource) -> String? {
        result
    }
}

private extension LocalizationStrategyTests {
    static func schema(defaultLocale: String?) throws -> AdaptyUISchema {
        let defaultLocalization = defaultLocale.map { #""default_localization": "\#($0)","# } ?? ""
        return try AdaptyUISchema(
            from: """
            {
              "format": "5.2.0",
              \(defaultLocalization)
              "screens": { "main": { "content": { "type": "text", "string_id": "title" } } },
              "localizations": [
                { "id": "en", "strings": [{ "id": "title", "value": "Title" }] },
                { "id": "fr", "strings": [{ "id": "title", "value": "Titre" }] }
              ]
            }
            """,
            configuration: .init(device: .phone)
        )
    }
}
