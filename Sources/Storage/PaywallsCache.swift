//
//  PaywallsCache.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 22.10.2022.
//

import Foundation

protocol PaywallsStorage {
    func setPaywalls(_: [VH<AdaptyPaywall>])
    func getPaywalls() -> [VH<AdaptyPaywall>]?
}

private extension AdaptyPaywall {
    var localeOrDefault: AdaptyLocale {
        var remoteConfigLocale = remoteConfig?.adaptyLocale
        if let locale = remoteConfigLocale, locale.equalLanguageCode(.defaultPaywallLocale) {
            remoteConfigLocale = nil
        }
        var viewConfigurationLocale = viewConfiguration?.locale
        if let locale = viewConfigurationLocale, locale.equalLanguageCode(.defaultPaywallLocale) {
            viewConfigurationLocale = nil
        }

        return switch (remoteConfigLocale, viewConfigurationLocale) {
        case (.none, .none): .defaultPaywallLocale
        case let (.some(locale), _),
             let (_, .some(locale)): locale
        }
    }

    func equalLanguageCode(_ paywall: AdaptyPaywall) -> Bool {
        localeOrDefault.equalLanguageCode(paywall.localeOrDefault)
    }
}

final class PaywallsCache {
    let profileId: String
    private let storage: PaywallsStorage
    private var paywallByPlacementId: [String: VH<AdaptyPaywall>]

    init(storage: PaywallsStorage, profileId: String) {
        self.profileId = profileId
        self.storage = storage
        paywallByPlacementId = storage.getPaywalls()?.asPaywallByPlacementId ?? [:]
    }

    func getPaywallByLocale(_ locale: AdaptyLocale, orDefaultLocale: Bool, withPlacementId placementId: String) -> VH<AdaptyPaywall>? {
        guard let paywall = paywallByPlacementId[placementId] else { return nil }
        let paywallLocale = paywall.value.localeOrDefault
        return if paywallLocale.equalLanguageCode(locale) {
            paywall
        } else if orDefaultLocale, paywallLocale.equalLanguageCode(.defaultPaywallLocale) {
            paywall
        } else {
            nil
        }
    }

    func getNewerPaywall(than paywall: AdaptyPaywall) -> AdaptyPaywall? {
        guard let cached: AdaptyPaywall = paywallByPlacementId[paywall.placementId]?.value,
              cached.equalLanguageCode(paywall) else { return nil }
        return paywall.version >= cached.version ? nil : cached
    }

    func savePaywall(_ paywall: AdaptyPaywall) {
        paywallByPlacementId[paywall.placementId] = VH(paywall, time: Date())
        storage.setPaywalls(Array(paywallByPlacementId.values))
    }
}
