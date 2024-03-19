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

private extension VH<AdaptyPaywall> {
    func equalLanguageCode(_ locale: AdaptyLocale) -> Bool {
        AdaptyLocale(id: value.locale).equalLanguageCode(locale)
    }

    func equalLanguageCode(_ paywall: VH<AdaptyPaywall>) -> Bool {
        equalLanguageCode(AdaptyLocale(id: paywall.value.locale))
    }
}

final class PaywallsCache {
    private let storage: PaywallsStorage
    private var paywallByPlacementId: [String: VH<AdaptyPaywall>]

    init(storage: PaywallsStorage) {
        self.storage = storage
        paywallByPlacementId = storage.getPaywalls()?.asPaywallByPlacementId ?? [:]
    }

    func getPaywallByLocale(_ locale: AdaptyLocale?, withPlacementId placementId: String) -> VH<AdaptyPaywall>? {
        guard let paywall = paywallByPlacementId[placementId] else { return nil }
        guard let locale else { return paywall }
        guard paywall.equalLanguageCode(locale) else { return nil }
        return paywall
    }

    func getPaywallByLocaleOrDefault(_ locale: AdaptyLocale?, withPlacementId placementId: String) -> VH<AdaptyPaywall>? {
        guard let paywall = paywallByPlacementId[placementId] else { return nil }
        if paywall.equalLanguageCode(.defaultPaywallLocale) { return paywall }
        guard let locale else { return nil }
        if paywall.equalLanguageCode(locale) { return paywall }
        return nil
    }

    private func getNewerPaywall(than paywall: VH<AdaptyPaywall>) -> VH<AdaptyPaywall>? {
        guard let cached: VH<AdaptyPaywall> = paywallByPlacementId[paywall.value.placementId],
              paywall.equalLanguageCode(cached) else { return nil }
        return paywall.value.version >= cached.value.version ? nil : cached
    }

    func savedPaywall(_ paywall: VH<AdaptyPaywall>) -> AdaptyPaywall {
        if let newer = getNewerPaywall(than: paywall) { return newer.value }
        paywallByPlacementId[paywall.value.placementId] = paywall
        storage.setPaywalls(Array(paywallByPlacementId.values))
        return paywall.value
    }
}
