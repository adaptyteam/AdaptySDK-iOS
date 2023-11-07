//
//  PaywallsCache.swift
//  Adapty
//
//  Created by Aleksei Valiano on 22.10.2022.
//

import Foundation

protocol PaywallsStorage {
    func setPaywalls(_ paywalls: [VH<AdaptyPaywall>])
    func getPaywalls() -> [VH<AdaptyPaywall>]?
}

fileprivate extension VH<AdaptyPaywall> {
    func equalLanguageCode(_ locale: AdaptyLocale) ->Bool {
        AdaptyLocale(id: value.locale).equalLanguageCode(locale)
    }

    func equalLanguageCode(_ paywall: VH<AdaptyPaywall>) ->Bool {
        equalLanguageCode(AdaptyLocale(id: paywall.value.locale))
    }
}

final class PaywallsCache {
    private let storage: PaywallsStorage
    private var paywalls: [String: VH<AdaptyPaywall>]

    init(storage: PaywallsStorage) {
        self.storage = storage
        paywalls = storage.getPaywalls()?.asDictionary ?? [:]
    }

    func getPaywallByLocale(_ locale: AdaptyLocale?, withId id: String) -> VH<AdaptyPaywall>? {
        guard let paywall = paywalls[id] else { return nil }
        guard let locale = locale else { return paywall }
        guard paywall.equalLanguageCode(locale) else { return nil }
        return paywall
    }

    func getPaywallByLocaleOrDefault(_ locale: AdaptyLocale?, withId id: String) -> VH<AdaptyPaywall>? {
        guard let paywall = paywalls[id] else { return nil }
        if paywall.equalLanguageCode(.defaultPaywallLocale)  { return paywall }
        guard let locale = locale else { return nil }
        if paywall.equalLanguageCode(locale)  { return paywall }
        return nil
    }

    private func getNewerPaywall(than paywall: VH<AdaptyPaywall>) -> VH<AdaptyPaywall>? {
        guard let cached: VH<AdaptyPaywall> = paywalls[paywall.value.id],
              paywall.equalLanguageCode(cached) else { return nil }
        return paywall.value.version >= cached.value.version ? nil : cached
    }

    func savedPaywall(_ paywall: VH<AdaptyPaywall>) -> AdaptyPaywall {
        if let newer = getNewerPaywall(than: paywall) { return newer.value }
        paywalls[paywall.value.id] = paywall
        storage.setPaywalls(Array(paywalls.values))
        return paywall.value
    }
}
