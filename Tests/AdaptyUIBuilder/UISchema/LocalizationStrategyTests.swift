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
        // the custom result is returned as is, even when the schema has no such id
        (custom: "xx", fallback: .auto, preferences: ["fr"], result: "xx"),
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

    @Test("No match and no default locale gives nil, the caller substitutes \"en\"")
    func noMatchNoDefault() async throws {
        let strategy = AdaptyUILocalizationStrategy.custom(resolver: FixedResolver(result: nil))
        #expect(try await strategy.resolve(for: ["de"], from: Self.schema(defaultLocale: nil)) == nil)
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
