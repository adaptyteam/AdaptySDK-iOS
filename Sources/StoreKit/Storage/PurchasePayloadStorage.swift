//
//  PurchasePayloadStorage.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 25.10.2022
//

import Foundation

private let log = Log.storage

@PurchasePayloadStorage.InternalActor
final class PurchasePayloadStorage {
    @globalActor
    actor InternalActor {
        package static let shared = InternalActor()
    }

    private enum Constants {
        static let deprecatedPaywallVariationsIds = "AdaptySDK_Cached_Variations_Ids"
        static let purchasePayload = "AdaptySDK_Purchase_Payload"
        static let persistentPaywallVariationsIds = "AdaptySDK_Variations_Ids"
        static let persistentOnboardingVariationsId = "AdaptySDK_Onboarding_Variation_Id"
    }

    private static let userDefaults = Storage.userDefaults

    private static var purchasePayload: [String: PurchasePayload] = (try? userDefaults.getJSON([String: PurchasePayload].self, forKey: Constants.purchasePayload)) ?? [:]

    private static func setPaywallVariationId(_ variationId: String, for productId: String, userId: AdaptyUserId) -> Bool {
        purchasePayload[productId] = .init(
            userId: userId,
            paywallVariationId: variationId,
            persistentPaywallVariationId: variationId,
            persistentOnboardingVariationId: persistentOnboardingVariationsId
        )
        try? userDefaults.setJSON(purchasePayload, forKey: Constants.purchasePayload)
        log.debug("Saving variationsIds for paywall")
        return true
    }

    private static func removePurchasePayload(for productId: String) -> Bool {
        guard purchasePayload.removeValue(forKey: productId) != nil else { return false }
        try? userDefaults.setJSON(purchasePayload, forKey: Constants.purchasePayload)
        log.debug("Remove purchase payload for productId = \(productId)")
        return true
    }

    private static var persistentPaywallVariationsIds: [String: String] = userDefaults
        .dictionary(forKey: Constants.persistentPaywallVariationsIds) as? [String: String] ?? [:]

    private static func setPersistentPaywallVariationId(_ variationId: String, for productId: String) -> Bool {
        guard variationId != persistentPaywallVariationsIds.updateValue(variationId, forKey: productId) else { return false }
        userDefaults.set(persistentPaywallVariationsIds, forKey: Constants.persistentPaywallVariationsIds)
        return true
    }

    private static var persistentOnboardingVariationsId: String? = userDefaults.string(forKey: Constants.persistentOnboardingVariationsId)

    private static func setPersistentOnboardingVariationId(_ variationId: String) -> Bool {
        guard variationId != persistentOnboardingVariationsId else { return false }
        persistentOnboardingVariationsId = variationId
        userDefaults.set(persistentOnboardingVariationsId, forKey: Constants.persistentOnboardingVariationsId)
        return true
    }

    static func migration(for userId: AdaptyUserId) {
        guard userDefaults.object(forKey: Constants.purchasePayload) == nil else { return }

        let paywallVariationsIds = userDefaults
            .dictionary(forKey: Constants.deprecatedPaywallVariationsIds) as? [String: String]

        guard let paywallVariationsIds, !paywallVariationsIds.isEmpty else { return }

        let onboardingId = userDefaults.string(forKey: Constants.persistentOnboardingVariationsId)

        let payloads = paywallVariationsIds.mapValues { variationId in
            PurchasePayload(
                userId: userId,
                paywallVariationId: variationId,
                persistentOnboardingVariationId: onboardingId
            )
        }

        do {
            try userDefaults.setJSON(payloads, forKey: Constants.purchasePayload)
            userDefaults.removeObject(forKey: Constants.deprecatedPaywallVariationsIds)
            log.info("PurchasePayloadStorage migration done")
        } catch {
            log.info("PurchasePayloadStorage migration failed with error: \(error)")
        }
    }

    static func clear() {
        purchasePayload = [:]
        persistentOnboardingVariationsId = nil

        userDefaults.removeObject(forKey: Constants.deprecatedPaywallVariationsIds)
        userDefaults.removeObject(forKey: Constants.persistentPaywallVariationsIds)
        userDefaults.removeObject(forKey: Constants.purchasePayload)
        userDefaults.removeObject(forKey: Constants.persistentOnboardingVariationsId)

        log.debug("Clear variationsIds for paywalls and onboarding.")
    }
}

extension PurchasePayloadStorage {
    func purchasePayload(for productId: String) -> PurchasePayload? { Self.purchasePayload[productId] }

    nonisolated func setPaywallVariationId(_ variationId: String, for productId: String, userId: AdaptyUserId) async {
        if await Self.setPaywallVariationId(variationId, for: productId, userId: userId) {
            await Adapty.trackSystemEvent(AdaptyInternalEventParameters(
                eventName: "did_set_variations_ids",
                params: [
                    "variation_by_product": Self.purchasePayload.mapValues(\.paywallVariationId),
                ]
            ))
        }
    }

    nonisolated func setPersistentPaywallVariationId(_ variationId: String, for productId: String) async {
        if await Self.setPersistentPaywallVariationId(variationId, for: productId) {
            await Adapty.trackSystemEvent(AdaptyInternalEventParameters(
                eventName: "did_set_variations_ids_persistent",
                params: [
                    "variation_by_product": Self.persistentPaywallVariationsIds,
                ]
            ))
        }
    }

    nonisolated func removePurchasePayload(for productId: String) async {
        guard await Self.removePurchasePayload(for: productId) else { return }

        await Adapty.trackSystemEvent(AdaptyInternalEventParameters(
            eventName: "did_set_variations_ids",
            params: [
                "variation_by_product": Self.purchasePayload.mapValues(\.paywallVariationId),
            ]
        ))
    }

    func onboardingVariationId() -> String? { Self.persistentOnboardingVariationsId }

    nonisolated func setOnboardingVariationId(_ variationId: String) async {
        if await Self.setPersistentOnboardingVariationId(variationId) {
            await Adapty.trackSystemEvent(AdaptyInternalEventParameters(
                eventName: "did_set_onboarding_variations_id",
                params: [
                    "onboarding_variation_id": variationId,
                ]
            ))
        }
    }
}
