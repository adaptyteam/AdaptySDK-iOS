//
//  PaywallStorage.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 21.04.2025.
//

import Foundation

private let log = Log.storage

@AdaptyActor
final class PaywallStorage: Sendable {
    private enum Constants {
        static let paywallStorageKey = "AdaptySDK_Cached_Purchase_Containers"
        static let paywallStorageVersionKey = "AdaptySDK_Cached_Purchase_Containers_Version"
        static let currentPaywallsStorageVersion = 3
    }

    private static let userDefaults = Storage.userDefaults

    static var paywallByPlacementId: [String: VH<AdaptyPaywall>] = {
        guard userDefaults.integer(forKey: Constants.paywallStorageVersionKey) == Constants.currentPaywallsStorageVersion else {
            return [:]
        }
        do {
            var userInfo = CodingUserInfo()
            userInfo.setRequestLocale(.defaultPlacementLocale)
            return try userDefaults.getJSON(
                [VH<AdaptyPaywall>].self,
                forKey: Constants.paywallStorageKey,
                userInfo: userInfo
            )?.asPaywallByPlacementId ?? [:]
        } catch {
            log.error(error.localizedDescription)
            return [:]
        }
    }()

    static func setPaywall(_ paywall: AdaptyPaywall) {
        paywallByPlacementId[paywall.placement.id] = VH(paywall, time: Date())
        let array = Array(paywallByPlacementId.values)
        guard !array.isEmpty else {
            userDefaults.removeObject(forKey: Constants.paywallStorageKey)
            return
        }

        do {
            try userDefaults.setJSON(array, forKey: Constants.paywallStorageKey)
            userDefaults.set(Constants.currentPaywallsStorageVersion, forKey: Constants.paywallStorageVersionKey)

            log.debug("Saving paywall success.")
        } catch {
            log.error("Saving paywall fail. \(error.localizedDescription)")
        }
    }

    static func clear() {
        paywallByPlacementId = [:]
        userDefaults.removeObject(forKey: Constants.paywallStorageKey)
        log.debug("Clear paywalls.")
    }
}

private extension Sequence<VH<AdaptyPaywall>> {
    var asPaywallByPlacementId: [String: VH<AdaptyPaywall>] {
        Dictionary(map { ($0.value.placement.id, $0) }, uniquingKeysWith: { first, second in
            first.value.placement.version > second.value.placement.version ? first : second
        })
    }
}
