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
    var viewConfigurationLocale: AdaptyLocale? {
        guard let paywall = self as? AdaptyPaywall else { return nil }
        return paywall.viewConfiguration?.locale
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


    
    func has(languageCode otherLocale: AdaptyLocale, orDefault: Bool = false) -> Bool {
        let locale = locale ?? .defaultPlacementLocale
        if locale.equalLanguageCode(otherLocale) { return true }
        else if orDefault, locale.equalLanguageCode(.defaultPlacementLocale) { return true }
        else { return false }
    }

    func has(variationId: String?) -> Bool {
        guard let variationId else { return true }
        return self.variationId == variationId
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

    func has(languageCode locale: AdaptyLocale, orDefault: Bool = false) -> Bool {
        value.has(languageCode: locale, orDefault: orDefault)
    }

    func has(variationId: String?) -> Bool {
        value.has(variationId: variationId)
    }
}
