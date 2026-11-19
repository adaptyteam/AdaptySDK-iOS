//
//  AdaptyUILocalizationStrategy.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 18.11.2026.
//

public struct AdaptyUILocalizationSource: Sendable {
    public let locales: [String]
    public let defaultLocale: String?
}

public enum AdaptyUILocalizationResolver: String, Sendable {
    case auto
    case legacy
    case system
}

public protocol AdaptyUICustomLocalizationResolver: Sendable {
    func resolve(for: [String], from: AdaptyUILocalizationSource) async -> String?
}

public struct AdaptyUILocalizationStrategy: Sendable {
    public static let auto = AdaptyUILocalizationStrategy(.auto)
    public static let legacy = AdaptyUILocalizationStrategy(.legacy)
    public static let system = AdaptyUILocalizationStrategy(.system)
    public static func custom(resolver: AdaptyUICustomLocalizationResolver, fallbackResolver: AdaptyUILocalizationResolver = .auto) -> Self {
        .init(fallbackResolver, custom: resolver)
    }

    let resolver: AdaptyUILocalizationResolver
    let customResolver: AdaptyUICustomLocalizationResolver?

    package init(
        _ resolver: AdaptyUILocalizationResolver,
        custom customResolver: AdaptyUICustomLocalizationResolver? = nil
    ) {
        self.resolver = resolver
        self.customResolver = customResolver
    }

    package func resolve(
        for preferences: [String],
        from schema: AdaptyUISchema
    ) async -> String? {
        let source = AdaptyUILocalizationSource(
            locales: schema.allLocalIds,
            defaultLocale: schema.defaultLocalId
        )

        if let locale = await customResolver?.resolve(for: preferences, from: source) {
            return locale
        }

        return switch resolver {
        case .auto where schema.formatVersion.isLegacyVersion:
            LegacyLocalizationResolver().resolve(for: preferences, from: source)
        case .auto,
             .system: SystemLocalizationResolver().resolve(for: preferences, from: source)
        case .legacy: LegacyLocalizationResolver().resolve(for: preferences, from: source)
        }
    }
}
