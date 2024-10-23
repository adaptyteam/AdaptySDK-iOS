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
        static let variationsIds = "AdaptySDK_Cached_Variations_Ids"
        static let persistentVariationsIds = "AdaptySDK_Variations_Ids"
    }

    private static let userDefaults = Storage.userDefaults

    private static var variationsIds: [String: String] = userDefaults
        .dictionary(forKey: Constants.variationsIds) as? [String: String] ?? [:]
    private static var persistentVariationsIds: [String: String] = userDefaults
        .dictionary(forKey: Constants.persistentVariationsIds) as? [String: String] ?? variationsIds

    fileprivate var variationsIds: [String: String] { Self.variationsIds }
    fileprivate var persistentVariationsIds: [String: String] { Self.persistentVariationsIds }

    fileprivate func setPersistentVariationId(_ variationId: String, for productId: String) -> Bool {
        guard variationId != Self.persistentVariationsIds.updateValue(variationId, forKey: productId) else { return false }
        Self.userDefaults.set(Self.persistentVariationsIds, forKey: Constants.persistentVariationsIds)
        return true
    }

    fileprivate func setVariationId(_ variationId: String, for productId: String) -> Bool {
        guard variationId != Self.variationsIds.updateValue(variationId, forKey: productId) else { return false }
        Self.userDefaults.set(Self.variationsIds, forKey: Constants.variationsIds)
        log.debug("Saving variationsIds for purchased product")
        return true
    }

    fileprivate func removeVariationId(for productId: String) -> Bool {
        guard Self.variationsIds.removeValue(forKey: productId) != nil else { return false }
        Self.userDefaults.set(Self.variationsIds, forKey: Constants.variationsIds)
        log.debug("Saving variationsIds for purchased product")
        return true
    }

    static func clear() {
        variationsIds = [:]
        persistentVariationsIds = [:]
        userDefaults.removeObject(forKey: Constants.variationsIds)
        userDefaults.removeObject(forKey: Constants.persistentVariationsIds)
        log.debug("Clear variationsIds for purchased product.")
    }
}

extension VariationIdStorage {
    nonisolated func getVariationIds(for productId: String) async -> (String?, String?) {
        await (variationsIds[productId], persistentVariationsIds[productId])
    }

    nonisolated func setVariationIds(_ variationId: String?, for productId: String) async {
        guard let variationId else { return }
        Task {
            if await setVariationId(variationId, for: productId) {
                await Adapty.trackSystemEvent(AdaptyInternalEventParameters(
                    eventName: "didset_variations_ids",
                    params: [
                        "variation_by_product": variationsIds,
                    ]
                ))
            }

            if await setPersistentVariationId(variationId, for: productId) {
                await Adapty.trackSystemEvent(AdaptyInternalEventParameters(
                    eventName: "didset_variations_ids_persistent",
                    params: [
                        "variation_by_product": persistentVariationsIds,
                    ]
                ))
            }
        }
    }

    nonisolated func removeVariationIds(for productId: String) {
        Task {
            guard await removeVariationId(for: productId) else { return }

            await Adapty.trackSystemEvent(AdaptyInternalEventParameters(
                eventName: "didset_variations_ids",
                params: [
                    "variation_by_product": variationsIds,
                ]
            ))
        }
    }
}
