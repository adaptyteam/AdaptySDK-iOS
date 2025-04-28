//
//  VariationIdStorage.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 25.10.2022
//

import Foundation

private let log = Log.storage

@VariationIdStorage.InternalActor
final class VariationIdStorage: Sendable {
    @globalActor
    actor InternalActor {
        package static let shared = InternalActor()
    }

    private enum Constants {
        static let paywallVariationsIds = "AdaptySDK_Cached_Variations_Ids"
        static let persistentPaywallVariationsIds = "AdaptySDK_Variations_Ids"
        static let persistentOnboardingVariationsId = "AdaptySDK_Onboarding_Variation_Id"
    }

    private static let userDefaults = Storage.userDefaults

    private static var paywallVariationsIds: [String: String] = userDefaults
        .dictionary(forKey: Constants.paywallVariationsIds) as? [String: String] ?? [:]
    private static var persistentPaywallVariationsIds: [String: String] = userDefaults
        .dictionary(forKey: Constants.persistentPaywallVariationsIds) as? [String: String] ?? paywallVariationsIds
    private static var persistentOnboardingVariationsId: String? = userDefaults.string(forKey: Constants.persistentOnboardingVariationsId)

    fileprivate var paywallVariationsIds: [String: String] { Self.paywallVariationsIds }
    fileprivate var persistentPaywallVariationsIds: [String: String] { Self.persistentPaywallVariationsIds }
    fileprivate var persistentOnboardingVariationsId: String? { Self.persistentOnboardingVariationsId }

    fileprivate func setPersistentOnboardingVariationId(_ variationId: String) -> Bool {
        guard variationId != Self.persistentOnboardingVariationsId else { return false }
        Self.persistentOnboardingVariationsId = variationId
        Self.userDefaults.set(Self.persistentOnboardingVariationsId, forKey: Constants.persistentOnboardingVariationsId)
        return true
    }

    fileprivate func setPersistentPaywallVariationId(_ variationId: String, for productId: String) -> Bool {
        guard variationId != Self.persistentPaywallVariationsIds.updateValue(variationId, forKey: productId) else { return false }
        Self.userDefaults.set(Self.persistentPaywallVariationsIds, forKey: Constants.persistentPaywallVariationsIds)
        return true
    }

    fileprivate func setPaywallVariationId(_ variationId: String, for productId: String) -> Bool {
        guard variationId != Self.paywallVariationsIds.updateValue(variationId, forKey: productId) else { return false }
        Self.userDefaults.set(Self.paywallVariationsIds, forKey: Constants.paywallVariationsIds)
        log.debug("Saving variationsIds for paywall")
        return true
    }

    fileprivate func removePaywallVariationId(for productId: String) -> Bool {
        guard Self.paywallVariationsIds.removeValue(forKey: productId) != nil else { return false }
        Self.userDefaults.set(Self.paywallVariationsIds, forKey: Constants.paywallVariationsIds)
        log.debug("Saving variationsIds for paywall")
        return true
    }

    static func clear() {
        paywallVariationsIds = [:]
        persistentPaywallVariationsIds = [:]
        persistentOnboardingVariationsId = nil

        userDefaults.removeObject(forKey: Constants.paywallVariationsIds)
        userDefaults.removeObject(forKey: Constants.persistentPaywallVariationsIds)
        userDefaults.removeObject(forKey: Constants.persistentOnboardingVariationsId)

        log.debug("Clear variationsIds for paywalls and onboarding.")
    }
}

extension VariationIdStorage {
    nonisolated func getPaywallVariationIds(for productId: String) async -> (String?, String?) {
        await (paywallVariationsIds[productId], persistentPaywallVariationsIds[productId])
    }

    nonisolated func getVariationIds(for productId: String) async -> (String?, String?, String?) {
        await (paywallVariationsIds[productId], persistentPaywallVariationsIds[productId], persistentOnboardingVariationsId)
    }

    nonisolated func getOnboardingVariationId() async -> String? {
        await persistentOnboardingVariationsId
    }

    nonisolated func setPaywallVariationIds(_ variationId: String?, for productId: String) async {
        guard let variationId else { return }
        Task {
            if await setPaywallVariationId(variationId, for: productId) {
                await Adapty.trackSystemEvent(AdaptyInternalEventParameters(
                    eventName: "did_set_variations_ids",
                    params: [
                        "variation_by_product": paywallVariationsIds,
                    ]
                ))
            }

            if await setPersistentPaywallVariationId(variationId, for: productId) {
                await Adapty.trackSystemEvent(AdaptyInternalEventParameters(
                    eventName: "did_set_variations_ids_persistent",
                    params: [
                        "variation_by_product": persistentPaywallVariationsIds,
                    ]
                ))
            }
        }
    }

    nonisolated func setOnboardingVariationId(_ variationId: String?) async {
        guard let variationId else { return }
        Task {
            if await setPersistentOnboardingVariationId(variationId) {
                await Adapty.trackSystemEvent(AdaptyInternalEventParameters(
                    eventName: "did_set_onboarding_variations_id",
                    params: [
                        "onboarding_variation_id": variationId,
                    ]
                ))
            }
        }
    }

    nonisolated func removePaywallVariationIds(for productId: String) {
        Task {
            guard await removePaywallVariationId(for: productId) else { return }

            await Adapty.trackSystemEvent(AdaptyInternalEventParameters(
                eventName: "did_set_variations_ids",
                params: [
                    "variation_by_product": paywallVariationsIds,
                ]
            ))
        }
    }
}
