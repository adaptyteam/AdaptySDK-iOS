//
//  AdaptyUILocalizationStrategy.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 18.11.2026.
//

public struct AdaptyUILocalizationSource: Sendable {
    package static let globalDefaultLocale: String = "en"
    public let locales: [String]
    public let defaultLocale: String?

    package init(locales: [String], defaultLocale: String?) {
        self.locales = locales
        self.defaultLocale = defaultLocale
    }

    var hasChoice: Bool {
        if let defaultLocale {
            Set(locales + [defaultLocale]).count > 1
        } else {
            Set(locales).count > 1
        }
    }

    var defaultOrFirstLocale: String? {
        defaultLocale ?? locales.first
    }

    func contains(_ locale: String) -> Bool {
        locales.contains(locale) || locale == defaultLocale
    }

    var globalDefault: String? {
        guard contains(AdaptyUILocalizationSource.globalDefaultLocale) else { return nil }
        return AdaptyUILocalizationSource.globalDefaultLocale
    }
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
        await resolve(
            for: preferences,
            from: schema.localizationSource,
            isLegacyVersion: schema.formatVersion.isLegacyVersion
        )
    }

    package func resolve(
        for preferences: [String],
        from source: AdaptyUILocalizationSource,
        isLegacyVersion: Bool
    ) async -> String? {
        guard source.hasChoice else { return source.defaultOrFirstLocale }
        if let locale = await customResolver?.resolve(for: preferences, from: source), source.contains(locale) {
            return locale
        }
        let resolved = switch resolver {
        case .legacy,
             .auto where isLegacyVersion:
            LegacyLocalizationResolver().resolve(for: preferences, from: source)
        case .system,
             .auto:
            SystemLocalizationResolver().resolve(for: preferences, from: source)
        }

        if let resolved { return resolved }

        return source.globalDefault
    }
}
