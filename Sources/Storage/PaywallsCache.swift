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
        var viewConfigurationLocale = viewConfiguration?.adaptyLocale
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

    func getPaywallByLocale(_ locale: AdaptyLocale?, withPlacementId placementId: String) -> VH<AdaptyPaywall>? {
        guard let paywall = paywallByPlacementId[placementId] else { return nil }
        let paywallLocale = paywall.value.localeOrDefault
        if paywallLocale.equalLanguageCode(.defaultPaywallLocale) { return paywall }
        guard let locale else { return paywall }
        return if paywallLocale.equalLanguageCode(locale) {
            paywall
        } else {
            nil
        }
    }

    private func getNewerPaywall(than paywall: AdaptyPaywall) -> AdaptyPaywall? {
        guard let cached: AdaptyPaywall = paywallByPlacementId[paywall.placementId]?.value,
              paywall.equalLanguageCode(cached) else { return nil }
        return paywall.version >= cached.version ? nil : cached
    }

    func savedPaywall(_ paywall: AdaptyPaywall) -> AdaptyPaywall {
        if let newer = getNewerPaywall(than: paywall) { return newer }
        paywallByPlacementId[paywall.placementId] = VH(paywall, time: Date())
        storage.setPaywalls(Array(paywallByPlacementId.values))
        return paywall
    }
}
