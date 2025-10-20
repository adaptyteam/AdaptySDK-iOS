//
//  PlacementContent.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.04.2025.
//

protocol PlacementContent: Sendable, Codable {
    var placement: AdaptyPlacement { get }
    var instanceIdentity: String { get }
    var variationId: String { get }
    var name: String { get }
    var remoteConfig: AdaptyRemoteConfig? { get }

    var requestLocale: AdaptyLocale { get set }
}

extension PlacementContent {
    private var viewConfigurationLocale: AdaptyLocale? {
        if let paywall = self as? AdaptyPaywall {
            paywall.viewConfiguration?.responseLocale
        } else if self is AdaptyOnboarding {
            nil
        } else {
            nil
        }
    }

    var locale: AdaptyLocale? {
        var remoteConfigLocale = remoteConfig?.adaptyLocale
        if remoteConfigLocale?.equalLanguageCode(.defaultPlacementLocale) ?? false {
            remoteConfigLocale = nil
        }
        var viewConfigurationLocale = viewConfigurationLocale
        if viewConfigurationLocale?.equalLanguageCode(.defaultPlacementLocale) ?? false {
            viewConfigurationLocale = nil
        }

        return switch (remoteConfigLocale, viewConfigurationLocale) {
        case (nil, nil): nil
        case let (locale?, _),
             let (_, locale?): locale
        }
    }

    var localeOrDefault: AdaptyLocale { locale ?? .defaultPlacementLocale }

    func equalLanguageCode(_ content: Self) -> Bool {
        localeOrDefault.equalLanguageCode(content.localeOrDefault)
    }
}

extension VH where Value: PlacementContent {
    var requestLocale: AdaptyLocale {
        get { value.requestLocale }
        mutating set {
            guard newValue != value.requestLocale else { return }
            self = mapValue {
                var content = $0
                content.requestLocale = newValue
                return content
            }
        }
    }
}
