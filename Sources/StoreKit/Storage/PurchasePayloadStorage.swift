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
        static let purchasePayloadByProductId = "AdaptySDK_Purchase_Payload_By_Product"
        static let purchasePayloadByTransactionId = "AdaptySDK_Purchase_Payload_By_Transaction"
        static let persistentPaywallVariationsIds = "AdaptySDK_Variations_Ids"
        static let persistentOnboardingVariationsId = "AdaptySDK_Onboarding_Variation_Id"
        static let unfinishedTransactionState = "AdaptySDK_Unfinished_Transaction_State"
    }

    private static let userDefaults = Storage.userDefaults

    private static var purchasePayloadByProductId: [String: PurchasePayload] = (try? userDefaults.getJSON([String: PurchasePayload].self, forKey: Constants.purchasePayloadByProductId)) ?? [:]

    private static func setPurchasePayload(_ payload: PurchasePayload, forProductId productId: String) -> Bool {
        guard payload != purchasePayloadByProductId.updateValue(payload, forKey: productId) else { return false }
        try? userDefaults.setJSON(purchasePayloadByProductId, forKey: Constants.purchasePayloadByProductId)
        log.debug("Saving variationsIds for paywall")
        return true
    }

    private static func removePurchasePayload(forProductId productId: String) -> Bool {
        guard purchasePayloadByProductId.removeValue(forKey: productId) != nil else { return false }
        try? userDefaults.setJSON(purchasePayloadByProductId, forKey: Constants.purchasePayloadByProductId)
        log.debug("Remove purchase payload for productId = \(productId)")
        return true
    }

    private static var purchasePayloadByTransactionId: [String: PurchasePayload] = (try? userDefaults.getJSON([String: PurchasePayload].self, forKey: Constants.purchasePayloadByTransactionId)) ?? [:]

    private static func setPurchasePayload(_ payload: PurchasePayload, forTransactionId transactionId: String) -> Bool {
        guard payload != purchasePayloadByTransactionId.updateValue(payload, forKey: transactionId) else { return false }
        try? userDefaults.setJSON(purchasePayloadByTransactionId, forKey: Constants.purchasePayloadByTransactionId)
        log.debug("Saving purchase payload for transactionId: \(transactionId)")
        return true
    }

    private static func removePurchasePayload(forTransactionId transactionId: String) -> Bool {
        guard purchasePayloadByTransactionId.removeValue(forKey: transactionId) != nil else { return false }
        try? userDefaults.setJSON(purchasePayloadByTransactionId, forKey: Constants.purchasePayloadByTransactionId)
        log.debug("Remove purchase payload for transactionId = \(transactionId)")
        return true
    }

    private static var persistentPaywallVariationsIds: [String: String] = userDefaults
        .dictionary(forKey: Constants.persistentPaywallVariationsIds) as? [String: String] ?? [:]

    private static func setPersistentPaywallVariationId(_ variationId: String, forProductId productId: String) -> Bool {
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

    private static var unfinishedTransactionState: [String: Bool] = userDefaults
        .dictionary(forKey: Constants.unfinishedTransactionState) as? [String: Bool] ?? [:]

    private static func setUnfinishedTransactionState(synced: Bool, forTransactionId transactionId: String) -> Bool {
        let changing = unfinishedTransactionState[transactionId].map { !$0 && synced } ?? true
        if changing {
            unfinishedTransactionState[transactionId] = synced
            userDefaults.set(unfinishedTransactionState, forKey: Constants.unfinishedTransactionState)
        }
        log.debug("Saving state (\(synced ? "unsynced" : "synced"))  for transactionId: \(transactionId)")
        return changing
    }

    private static func removeUnfinishedTransactionState(forTransactionId transactionId: String) -> Bool {
        guard unfinishedTransactionState.removeValue(forKey: transactionId) != nil else { return false }
        userDefaults.set(unfinishedTransactionState, forKey: Constants.unfinishedTransactionState)
        log.debug("Remove state for transactionId: \(transactionId)")
        return true
    }

    static func removeAllUnfinishedTransactionState() -> Bool {
        guard !unfinishedTransactionState.isEmpty else { return false }
        unfinishedTransactionState = [:]
        userDefaults.removeObject(forKey: Constants.unfinishedTransactionState)
        log.debug("Remove all states for transaction")
        return true
    }

    static func migration(for userId: AdaptyUserId) {
        guard userDefaults.object(forKey: Constants.purchasePayloadByProductId) == nil else { return }

        let paywallVariationsIds = userDefaults
            .dictionary(forKey: Constants.deprecatedPaywallVariationsIds) as? [String: String]

        guard let paywallVariationsIds, !paywallVariationsIds.isEmpty else { return }

        let onboardingId = userDefaults.string(forKey: Constants.persistentOnboardingVariationsId)

        let payloads = paywallVariationsIds.mapValues { variationId in
            PurchasePayload(
                userId: userId,
                paywallVariationId: variationId,
                persistentPaywallVariationId: variationId,
                persistentOnboardingVariationId: onboardingId
            )
        }

        do {
            try userDefaults.setJSON(payloads, forKey: Constants.purchasePayloadByProductId)
            userDefaults.removeObject(forKey: Constants.deprecatedPaywallVariationsIds)
            log.info("PurchasePayloadStorage migration done")
        } catch {
            log.info("PurchasePayloadStorage migration failed with error: \(error)")
        }
    }

    static func clear() {
        purchasePayloadByProductId = [:]
        persistentOnboardingVariationsId = nil

        userDefaults.removeObject(forKey: Constants.deprecatedPaywallVariationsIds)
        userDefaults.removeObject(forKey: Constants.persistentPaywallVariationsIds)
        userDefaults.removeObject(forKey: Constants.purchasePayloadByProductId)
        userDefaults.removeObject(forKey: Constants.purchasePayloadByTransactionId)
        userDefaults.removeObject(forKey: Constants.persistentOnboardingVariationsId)
        userDefaults.removeObject(forKey: Constants.unfinishedTransactionState)

        log.debug("Clear variationsIds for paywalls and onboarding.")
    }
}

extension PurchasePayloadStorage {
    func purchasePayload(byProductId productId: String, orCreateFor userId: AdaptyUserId) -> PurchasePayload {
        Self.purchasePayloadByProductId[productId] ?? .init(
            userId: userId,
            persistentPaywallVariationId: Self.persistentPaywallVariationsIds[productId],
            persistentOnboardingVariationId: Self.persistentOnboardingVariationsId
        )
    }

    func setPaywallVariationId(_ variationId: String, productId: String, userId: AdaptyUserId) {
        if Self.setPurchasePayload(
            .init(
                userId: userId,
                paywallVariationId: variationId,
                persistentPaywallVariationId: variationId,
                persistentOnboardingVariationId: Self.persistentOnboardingVariationsId
            ),
            forProductId: productId
        ) {
            Adapty.trackSystemEvent(AdaptyInternalEventParameters(
                eventName: "did_set_variations_ids",
                params: [
                    "payload_by_product": Self.purchasePayloadByProductId,
                ]
            ))
        }

        if Self.setPersistentPaywallVariationId(variationId, forProductId: productId) {
            Adapty.trackSystemEvent(AdaptyInternalEventParameters(
                eventName: "did_set_variations_ids_persistent",
                params: [
                    "variation_by_product": Self.persistentPaywallVariationsIds,
                ]
            ))
        }
    }

    func removePurchasePayload(forProductId productId: String) {
        guard Self.removePurchasePayload(forProductId: productId) else { return }
        Adapty.trackSystemEvent(AdaptyInternalEventParameters(
            eventName: "did_set_variations_ids",
            params: [
                "payload_by_product": Self.purchasePayloadByProductId,
            ]
        ))
    }

    func purchasePayload(byTransaction transaction: SKTransaction, orCreateFor userId: AdaptyUserId) -> PurchasePayload {
        if let payload = Self.purchasePayloadByTransactionId[transaction.unfIdentifier] {
            return payload
        }

        let payload = purchasePayload(byProductId: transaction.unfProductId, orCreateFor: userId)
        setPurchasePayload(payload, forTransaction: transaction)
        return payload
    }

    func setPurchasePayload(_ payload: PurchasePayload, forTransaction transaction: SKTransaction) {
        if Self.setPurchasePayload(
            payload,
            forTransactionId: transaction.unfIdentifier
        ) {
            Adapty.trackSystemEvent(AdaptyInternalEventParameters(
                eventName: "did_set_variations_ids",
                params: [
                    "payload_by_transaction": Self.purchasePayloadByTransactionId,
                ]
            ))
        }
        removePurchasePayload(forProductId: transaction.unfProductId)
    }

    func removePurchasePayload(forTransaction transaction: SKTransaction) {
        if Self.removePurchasePayload(forTransactionId: transaction.unfIdentifier) {
            Adapty.trackSystemEvent(AdaptyInternalEventParameters(
                eventName: "did_set_variations_ids",
                params: [
                    "payload_by_transaction": Self.purchasePayloadByTransactionId,
                ]
            ))
        }
        removePurchasePayload(forProductId: transaction.unfProductId)
    }

    func onboardingVariationId() -> String? { Self.persistentOnboardingVariationsId }

    func setOnboardingVariationId(_ variationId: String) {
        if Self.setPersistentOnboardingVariationId(variationId) {
            Adapty.trackSystemEvent(AdaptyInternalEventParameters(
                eventName: "did_set_onboarding_variations_id",
                params: [
                    "onboarding_variation_id": variationId,
                ]
            ))
        }
    }

    func unfinishedTransactionIds() -> Set<String> {
        Set(Self.unfinishedTransactionState.keys)
    }

    func isSyncedTransaction(_ transactionId: String) -> Bool {
        Self.unfinishedTransactionState[transactionId] ?? false
    }

    func addUnfinishedTransaction(_ transactionId: String) -> Bool {
        let added = Self.setUnfinishedTransactionState(synced: false, forTransactionId: transactionId)
        if added {
            log.debug("Storage after add state of unfinishedTransaction:\(transactionId) all:\(Self.unfinishedTransactionState)")
            Adapty.trackSystemEvent(AdaptyInternalEventParameters(
                eventName: "did_change_unfinished_transaction",
                params: [
                    "state": Self.unfinishedTransactionState,
                ]
            ))
        }
        return added
    }

    func canFinishSyncedTransaction(_ transactionId: String) -> Bool {
        guard Self.unfinishedTransactionState[transactionId] != nil else { return true }
        if Self.setUnfinishedTransactionState(synced: true, forTransactionId: transactionId) {
            log.debug("Storage after change state of unfinishedTransaction:\(transactionId) all: \(Self.unfinishedTransactionState)")

            Adapty.trackSystemEvent(AdaptyInternalEventParameters(
                eventName: "did_change_unfinished_transaction",
                params: [
                    "state": Self.unfinishedTransactionState,
                ]
            ))
        }
        return false
    }

    func removeUnfinishedTransaction(_ transactionId: String) {
        guard Self.unfinishedTransactionState[transactionId] != nil else { return }
        if Self.removeUnfinishedTransactionState(forTransactionId: transactionId) {
            log.debug("Storage after remove state of unfinishedTransaction:\(transactionId) all: \(Self.unfinishedTransactionState)")
            Adapty.trackSystemEvent(AdaptyInternalEventParameters(
                eventName: "did_change_unfinished_transaction",
                params: [
                    "state": Self.unfinishedTransactionState,
                ]
            ))
        }
    }
}
