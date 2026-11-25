//
//  AdaptyUILocalizationStrategy.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 18.11.2026.
//

/// The localizations a flow offers, passed to an ``AdaptyUICustomLocalizationResolver``.
public struct AdaptyUILocalizationSource: Sendable {
    package static let globalDefaultLocale: String = "en"

    /// Identifiers of the flow's localizations, spelled as in the flow. Their order is not meaningful.
    public let locales: [String]
    /// Identifier of the flow's default localization, or `nil` when the flow has none.
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

/// A built-in way of choosing a flow localization from the preferred locales.
public enum AdaptyUILocalizationResolver: String, Sendable {
    /// ``legacy`` for flows made in the legacy Paywall Builder, ``system`` for all other flows.
    case auto
    /// The algorithm of Adapty SDKs before 4.0, unchanged. Only the first preferred locale is used:
    /// `_` becomes `-`, the identifier is lowercased, and subtags are removed from the right until
    /// it equals a localization identifier of the flow exactly. Without a match, the flow's default
    /// localization is used.
    case legacy
    /// The way iOS chooses an app's language (`Bundle.preferredLocalizations`). The preferred locales
    /// are tried in order, and each one takes the closest localization the flow has: case and `_` or `-`
    /// do not matter, and region, script and language synonyms are taken into account (for example,
    /// `pt-BR` takes `pt`, `zh-TW` takes `zh-Hant`, `es-MX` takes `es-419`). A preferred locale that
    /// matches no localization of the flow is skipped, and the next one is tried. Without a match, the
    /// flow's default localization is used.
    case system
}

/// Chooses a flow localization when the built-in resolvers do not fit, or adjusts their choice.
/// Return `nil` to leave the choice to the fallback resolver.
public protocol AdaptyUICustomLocalizationResolver: Sendable {
    /// Returns the identifier of the localization to show the flow in.
    ///
    /// The returned identifier must be one of the flow's localizations. An identifier the flow does not
    /// have is ignored, and the fallback resolver chooses.
    ///
    /// Called while the flow configuration is created, possibly not on the main thread. Although the call
    /// is asynchronous, `getFlowConfiguration` waits for the answer, so any time spent here delays the
    /// flow. Return as fast as possible and avoid network requests.
    ///
    /// - Parameters:
    ///   - for: the preferred locales passed to `getFlowConfiguration`, in order, trimmed and without empty entries.
    ///   - from: the localizations the flow has.
    func resolve(for: [String], from: AdaptyUILocalizationSource) async -> String?
}

/// How a flow localization is chosen from the preferred locales passed to `getFlowConfiguration`.
///
/// With an empty list of preferred locales, every built-in resolver gives the flow's default localization.
public struct AdaptyUILocalizationStrategy: Sendable {
    /// ``AdaptyUILocalizationResolver/legacy`` for flows made in the legacy Paywall Builder,
    /// ``AdaptyUILocalizationResolver/system`` for all other flows. The default.
    public static let auto = AdaptyUILocalizationStrategy(.auto)
    /// See ``AdaptyUILocalizationResolver/legacy``.
    public static let legacy = AdaptyUILocalizationStrategy(.legacy)
    /// See ``AdaptyUILocalizationResolver/system``.
    public static let system = AdaptyUILocalizationStrategy(.system)
    /// Asks `resolver` first and uses `fallbackResolver` when it returns `nil`.
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
