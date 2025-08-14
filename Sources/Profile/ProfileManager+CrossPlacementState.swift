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

        guard let manager = try profileManager(with: profileId) else {
            throw .profileWasChanged()
        }
        manager.saveCrossPlacementState(state)
    }
}

extension ProfileManager {
    func syncCrossPlacementState() async throws(AdaptyError) {
        try await Adapty.activatedSDK.syncCrossPlacementState(profileId: profileId)
    }

    func saveCrossPlacementState(_ newState: CrossPlacementState) {
        let oldState = storage.crossPlacementState

        if let oldState {
            guard oldState.version < newState.version else { return }
        }

        Log.crossAB.verbose("updateProfile version = \(newState.version), newValue = \(newState.variationIdByPlacements), oldValue = \(oldState?.variationIdByPlacements.description ?? "DISABLED")")

        storage.setCrossPlacementState(newState)
    }
}
