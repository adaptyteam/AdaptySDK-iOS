//
//  BackendIntroductoryOfferEligibilityStorage.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.09.2022.
//

import Foundation

private let log = Log.storage

@AdaptyActor
final class BackendIntroductoryOfferEligibilityStorage: Sendable {
    private enum Constants {
        static let ineligibleProductIds = "AdaptySDK_Cached_Backend_Ineligible_Products"
    }

    private static let userDefaults = Storage.userDefaults

    private static var ineligibleProductIds = Set(
        userDefaults.stringArray(forKey: Constants.ineligibleProductIds) ?? []
    )

    private static var lastResponse: (hash: String?, eligibleProductIds: [String])?

    func getLastResponse() -> (hash: String?, eligibleProductIds: [String])? { Self.lastResponse }

    func getIneligibleProductIds() -> Set<String> { Self.ineligibleProductIds }

    private func setIneligibleProductIds<S: Sequence>(_ ids: S) where S.Element == String {
        let old = Self.ineligibleProductIds
        let union = old.union(ids)

        guard union.count > old.count else { return }

        Self.userDefaults.setValue(Array(union), forKey: Constants.ineligibleProductIds)
        Self.ineligibleProductIds = union
        log.debug("setIneligibleProductIds success.")
    }

    func save(_ response: VH<[BackendIntroductoryOfferEligibilityState]>) -> [String] {
        var ineligibleProductIds = [String]()
        var eligibleProductIds = [String]()

        for state in response.value {
            guard state.value else {
                ineligibleProductIds.append(state.vendorId)
                continue
            }
            guard Self.ineligibleProductIds.contains(state.vendorId) else { continue }
            eligibleProductIds.append(state.vendorId)
        }

        setIneligibleProductIds(ineligibleProductIds)
        Self.lastResponse = (response.hash, eligibleProductIds)
        return eligibleProductIds
    }

    static func clear() {
        ineligibleProductIds = []
        lastResponse = nil
        userDefaults.removeObject(forKey: Constants.ineligibleProductIds)
        log.debug("Clear products.")
    }
}
