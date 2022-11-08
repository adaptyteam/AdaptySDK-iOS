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

    func getPaywall(byId id: String) -> VH<AdaptyPaywall>? { paywalls[id] }

    private func canStore(_ paywall: VH<AdaptyPaywall>) -> Bool {
        guard let cached: VH<AdaptyPaywall> = getPaywall(byId: paywall.value.id) else { return true }
        return paywall.value.version > cached.value.version
    }

    func setPaywall(_ paywall: VH<AdaptyPaywall>) {
        guard canStore(paywall) else { return }
        paywalls[paywall.value.id] = paywall
        storage.setPaywalls(Array(paywalls.values))
    }
}
