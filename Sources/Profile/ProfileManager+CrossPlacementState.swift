//
//  ProfileManager+CrossPlacementState.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 02.04.2025.
//

private extension Adapty {
    func syncCrossPlacementState(userId: AdaptyUserId) async throws(AdaptyError) {
        let state: CrossPlacementState

        do {
            state = try await httpSession.fetchCrossPlacementState(userId: userId)
        } catch {
            throw error.asAdaptyError
        }

        guard let manager = try profileManager(withProfileId: userId) else {
            throw .profileWasChanged()
        }

        await CrossPlacementStorage.set(crossPlacementState: state, for: userId)
    }
}

extension ProfileManager {
    func syncCrossPlacementState() async throws(AdaptyError) {
        try await Adapty.activatedSDK.syncCrossPlacementState(userId: userId)
    }
}
