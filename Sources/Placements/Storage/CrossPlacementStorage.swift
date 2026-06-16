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
    }

    private static let userDefaults = Storage.userDefaults

    private static var crossPlacementState: CrossPlacementState? = {
        do {
            return try userDefaults.getJSON(CrossPlacementState.self, forKey: Constants.crossPlacementStateKey)
        } catch {
            log.warn(error.localizedDescription)
            return nil
        }
    }()

    // TODO: per-profile state not implemented yet. `userId` is ignored and a single
    // global state is returned, so one profile's cross-placement assignment leaks into
    // another. Key the storage by `userId.profileId`. To be fixed in a follow-up commit.
    static func state(for _: AdaptyUserId) -> CrossPlacementState? {
        crossPlacementState
    }

    static func set(draw: AdaptyPlacement.Draw<some PlacementContent>) {
        guard
            let currentValue = crossPlacementState,
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
        let oldValue = crossPlacementState
        guard newValue.isNewerThan(oldValue) else { return }

        log.verbose("update crossPlacementState \(userId) to version = \(newValue.version), newValue = \(newValue.variationIdByPlacements), oldValue = \(oldValue?.variationIdByPlacements.description ?? "DISABLED")")

        save(crossPlacementState: newValue, for: userId)
    }

    // TODO: `userId` is ignored — state is persisted under one global key shared by all
    // profiles. Persist per `userId.profileId`. To be fixed in a follow-up commit.
    private static func save(crossPlacementState newValue: CrossPlacementState, for userId: AdaptyUserId) {
        crossPlacementState = newValue
        do {
            try userDefaults.setJSON(newValue, forKey: Constants.crossPlacementStateKey)
            log.verbose("saving crossPlacementState success.")
        } catch {
            log.error("saving crossPlacementState fail. \(error.localizedDescription)")
        }
    }

    // TODO: ignores `userId` and wipes the single global key, so it also clears the
    // CURRENT profile's state instead of only other profiles'. Once storage is keyed by
    // profileId, remove only entries whose profileId != userId.profileId.
    // To be fixed in a follow-up commit.
    //
    // KNOWN BUG (present now): on the profile-changed branch of `createNewProfileOnServer`
    // (Adapty.swift), `ProfileStorage.clearProfile` schedules this method on an un-awaited
    // `Task { @StorageActor }`, while `CrossPlacementStorage.set(crossPlacementState:for:)`
    // is awaited inline. Both run on @StorageActor with undefined ordering; if this clear
    // lands AFTER `set`, it wipes the just-fetched cross-placement state. Resolved once the
    // per-profile fix above lands (removing only OTHER profiles won't touch the current one).
    static func removeOtherProfiles(_: AdaptyUserId) {
        userDefaults.removeObject(forKey: Constants.crossPlacementStateKey)
        crossPlacementState = nil
        log.verbose("clear CrossPlacementStorage")
    }
}
