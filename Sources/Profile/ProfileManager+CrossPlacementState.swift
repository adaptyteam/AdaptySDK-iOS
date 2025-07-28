//
//  ProfileManager+CrossPlacementState.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 02.04.2025.
//

private extension Adapty {
    func syncCrossPlacementState(profileId: String) async throws(AdaptyError) {
        let state: CrossPlacementState
        do {
            state = try await httpSession.fetchCrossPlacementState(profileId: profileId)
        } catch {
            throw error.asAdaptyError
        }
        try saveCrossPlacementState(state, forProfileId: profileId)
    }

    @AdaptyActor
    private func saveCrossPlacementState(_ newState: CrossPlacementState, forProfileId profileId: String) throws(AdaptyError) {
        guard let manager = try profileManager(with: profileId) else {
            throw .profileWasChanged()
        }

        let storage = manager.storage
        let oldState = storage.crossPlacementState
        guard (oldState?.version ?? 0) < newState.version else { return }

        Log.crossAB.verbose("updateProfile version = \(newState.version), newValue = \(newState.variationIdByPlacements), oldValue = \(oldState?.variationIdByPlacements.description ?? "DISABLED")")

        storage.setCrossPlacementState(newState)
    }
}

extension ProfileManager {
    func syncCrossPlacementState() async throws(AdaptyError) {
        try await Adapty.activatedSDK.syncCrossPlacementState(profileId: profileId)
    }
}
