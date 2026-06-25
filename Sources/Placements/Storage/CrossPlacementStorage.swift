//
//  CrossPlacementStorage.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 21.08.2025.
//

import Foundation

private let log = Log.crossAB

@StorageActor
final class CrossPlacementStorage {
    private enum Constants {
        static let crossPlacementStateKey = "AdaptySDK_Cross_Placement_State"
        static let profileIdKey = "AdaptySDK_Profile_Id"
    }

    private static let userDefaults = Storage.userDefaults

    private static var statesByProfileId: [String: CrossPlacementState] = {
        if let map = try? userDefaults.getJSON([String: CrossPlacementState].self, forKey: Constants.crossPlacementStateKey) {
            return map
        }

        guard
            let legacyState = try? userDefaults.getJSON(CrossPlacementState.self, forKey: Constants.crossPlacementStateKey),
            let profileId = userDefaults.string(forKey: Constants.profileIdKey)
        else {
            userDefaults.removeObject(forKey: Constants.crossPlacementStateKey)
            return [:]
        }

        let migrated = [profileId: legacyState]
        try? userDefaults.setJSON(migrated, forKey: Constants.crossPlacementStateKey)
        log.verbose("migrated legacy cross-placement state to profile \(profileId)")
        return migrated
    }()

    static func state(for userId: AdaptyUserId) -> CrossPlacementState? {
        statesByProfileId[userId.profileId]
    }

    static func set(draw: AdaptyPlacement.Draw<some PlacementContent>) {
        guard
            let currentValue = statesByProfileId[draw.userId.profileId],
            currentValue.canParticipateInABTest,
            draw.participatesInCrossPlacementABTest
        else { return }
        save(
            crossPlacementState: .init(
                variationIdByPlacements: draw.variationIdByPlacements,
                version: currentValue.version
            ),
            for: draw.userId
        )
    }

    static func set(crossPlacementState newValue: CrossPlacementState, for userId: AdaptyUserId) {
        let oldValue = statesByProfileId[userId.profileId]
        guard newValue.isNewerThan(oldValue) else { return }

        log.verbose("update crossPlacementState \(userId) to version = \(newValue.version), newValue = \(newValue.variationIdByPlacements), oldValue = \(oldValue?.variationIdByPlacements.description ?? "DISABLED")")

        save(crossPlacementState: newValue, for: userId)
    }

    private static func save(crossPlacementState newValue: CrossPlacementState, for userId: AdaptyUserId) {
        statesByProfileId[userId.profileId] = newValue
        persist()
    }

    private static func persist() {
        do {
            if statesByProfileId.isEmpty {
                userDefaults.removeObject(forKey: Constants.crossPlacementStateKey)
            } else {
                try userDefaults.setJSON(statesByProfileId, forKey: Constants.crossPlacementStateKey)
            }
            log.verbose("saving crossPlacementState success.")
        } catch {
            log.error("saving crossPlacementState fail. \(error.localizedDescription)")
        }
    }

    static func removeOtherProfiles(_ userId: AdaptyUserId) {
        let profileId = userId.profileId
        guard statesByProfileId.contains(where: { $0.key != profileId }) else { return }
        statesByProfileId = statesByProfileId.filter { $0.key == profileId }
        persist()
        log.verbose("clear cross-placement state of other profiles")
    }
}
