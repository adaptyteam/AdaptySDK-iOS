//
//  PaywallsCache.swift
//  Adapty
//
//  Created by Aleksei Valiano on 22.10.2022.
//

import Foundation

protocol PaywallsStorage {
    func setPaywalls(_ paywalls: [VH<Paywall>])
    func getPaywalls() -> [VH<Paywall>]?
}

final class PaywallsCache {
    private let storage: PaywallsStorage
    private var paywalls: [String: VH<Paywall>]

    init(storage: PaywallsStorage) {
        self.storage = storage
        paywalls = storage.getPaywalls()?.asDictionary ?? [:]
    }

    func getPaywall(byId id: String) -> VH<Paywall>? { paywalls[id] }

    private func canStore(_ paywall: VH<Paywall>) -> Bool {
        guard let cached: VH<Paywall> = getPaywall(byId: paywall.value.id) else { return true }
        return paywall.value.version > cached.value.version
    }

    func setPaywall(_ paywall: VH<Paywall>) {
        guard canStore(paywall) else { return }
        paywalls[paywall.value.id] = paywall
        storage.setPaywalls(Array(paywalls.values))
    }
}
