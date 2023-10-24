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

final class PaywallsCache {
    private let storage: PaywallsStorage
    private var paywalls: [String: VH<AdaptyPaywall>]

    init(storage: PaywallsStorage) {
        self.storage = storage
        paywalls = storage.getPaywalls()?.asDictionary ?? [:]
    }

//    func getPaywall(byId id: String, locale: String = AdaptyPaywall.defaultLocale) -> VH<AdaptyPaywall>? {
//        guard let paywall = paywalls[id], paywall.value.locale == locale else { return nil }
//        return paywall
//    }

    private func sameLocale(_ first: String, _ second: String) -> Bool {
        guard let first = first.components(separatedBy: "-").first?.lowercased(),
              let second = second.components(separatedBy: "-").first?.lowercased(),
              !first.isEmpty, !second.isEmpty else { return false }
        return first == second 
    }

    func getPaywallByLocaleOrDefault(_ locale: String?, withId id: String) -> VH<AdaptyPaywall>? {
        guard let paywall = paywalls[id] else { return nil }
        if sameLocale(paywall.value.locale, AdaptyPaywall.defaultLocale) { return paywall }
        guard let locale = locale else { return nil }
        if sameLocale(paywall.value.locale, locale) { return paywall }
        return nil
    }

    private func getNewerPaywall(than paywall: VH<AdaptyPaywall>) -> VH<AdaptyPaywall>? {
        guard let cached: VH<AdaptyPaywall> = paywalls[paywall.value.id],
              sameLocale(paywall.value.locale, cached.value.locale) else { return nil }
        return paywall.value.version >= cached.value.version ? nil : cached
    }

    func savedPaywall(_ paywall: VH<AdaptyPaywall>) -> AdaptyPaywall {
        if let newer = getNewerPaywall(than: paywall) { return  newer.value }
        paywalls[paywall.value.id] = paywall
        storage.setPaywalls(Array(paywalls.values))
        return paywall.value
    }
}
