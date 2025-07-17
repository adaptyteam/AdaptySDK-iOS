//
//  ProfileManager+CrossPlacementState.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 02.04.2025.
//

private extension Adapty {
    func syncCrossPlacementState(profileId: String) async throws {
        let state = try await httpSession.fetchCrossPlacementState(
            profileId: profileId
        )

        try saveCrossPlacementState(state, forProfileId: profileId)
    }

    @AdaptyActor
    private func saveCrossPlacementState(_ newState: CrossPlacementState, forProfileId profileId: String) throws {
        guard let manager = try profileManager(with: profileId) else {
            throw AdaptyError.profileWasChanged()
        }

        let storage = manager.storage
        let oldState = storage.crossPlacementState
        guard (oldState?.version ?? 0) < newState.version else { return }

        Log.crossAB.verbose("updateProfile version = \(newState.version), newValue = \(newState.variationIdByPlacements), oldValue = \(oldState?.variationIdByPlacements.description ?? "DISABLED")")

        storage.setCrossPlacementState(newState)
    }
}

extension ProfileManager {
    func syncCrossPlacementState() async throws {
        try await Adapty.activatedSDK.syncCrossPlacementState(profileId: profileId)
    }
}
