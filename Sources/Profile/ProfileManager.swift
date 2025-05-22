//
//  ProfileManager.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.10.2022.
//

import Foundation

@AdaptyActor
final class ProfileManager: Sendable {
    nonisolated let profileId: String
    var profile: VH<AdaptyProfile>
    var onceSentEnvironment: SentEnvironment

    let storage: ProfileStorage
    let placementStorage = PlacementStorage()
    let backendIntroductoryOfferEligibilityStorage = BackendIntroductoryOfferEligibilityStorage()

    @AdaptyActor
    init(
        storage: ProfileStorage,
        profile: VH<AdaptyProfile>,
        sentEnvironment: SentEnvironment
    ) {
        let profileId = profile.value.profileId
        self.profileId = profileId
        self.profile = profile
        self.onceSentEnvironment = sentEnvironment
        self.storage = storage

        Task { [weak self] in
            Adapty.optionalSDK?.updateASATokenIfNeed(for: profile)

            if sentEnvironment == .none {
                _ = await self?.getProfile()
            } else {
                self?.syncTransactionsIfNeed(for: profileId)
            }

            Adapty.callDelegate { $0.didLoadLatestProfile(profile.value) }
        }
    }
}

extension ProfileManager {
    nonisolated func syncTransactionsIfNeed(for profileId: String) { // TODO: extract this code from ProfileManager
        Task { @AdaptyActor [weak self] in
            guard let sdk = Adapty.optionalSDK,
                  let self,
                  !self.storage.syncedTransactions
            else { return }

            try? await sdk.syncTransactions(for: profileId)
        }
    }

    func updateProfile(params: AdaptyProfileParameters) async throws -> AdaptyProfile {
        try await syncProfile(params: params)
    }

    func getProfile() async -> AdaptyProfile {
        syncTransactionsIfNeed(for: profileId)
        return await (try? syncProfile(params: nil)) ?? profile.value
    }

    private func syncProfile(params: AdaptyProfileParameters?) async throws -> AdaptyProfile {
        if let analyticsDisabled = params?.analyticsDisabled {
            storage.setExternalAnalyticsDisabled(analyticsDisabled)
        }

        let meta = await onceSentEnvironment.getValueIfNeedSend(
            analyticsDisabled: (params?.analyticsDisabled ?? false) || storage.externalAnalyticsDisabled
        )

        return try await Adapty.activatedSDK.syncProfile(
            profile: profile,
            params: params,
            environmentMeta: meta
        )
    }

    func saveResponse(_ newProfile: VH<AdaptyProfile>?) {
        guard let newProfile,
              profile.value.profileId == newProfile.value.profileId,
              !profile.hash.nonOptionalIsEqual(newProfile.hash),
              profile.value.version <= newProfile.value.version
        else { return }

        profile = newProfile
        storage.setProfile(newProfile)

        Adapty.callDelegate { $0.didLoadLatestProfile(newProfile.value) }
    }
}

extension Adapty {
    func syncTransactions(for profileId: String) async throws {
        let response = try await transactionManager.syncTransactions(for: profileId)

        if profileStorage.profileId == profileId {
            profileStorage.setSyncedTransactions(true)
        }
        profileManager?.saveResponse(response)
    }

    func saveResponse(_ newProfile: VH<AdaptyProfile>, syncedTransaction: Bool = false) {
        if syncedTransaction, profileStorage.profileId == newProfile.value.profileId {
            profileStorage.setSyncedTransactions(true)
        }
        profileManager?.saveResponse(newProfile)
    }
}

private extension Adapty {
    func syncProfile(profile old: VH<AdaptyProfile>, params: AdaptyProfileParameters?, environmentMeta meta: Environment.Meta?) async throws -> AdaptyProfile {
        do {
            let response = try await httpSession.syncProfile(
                profileId: old.value.profileId,
                parameters: params,
                environmentMeta: meta,
                responseHash: old.hash
            )

            if let manager = try profileManager(with: old.value.profileId) {
                if let meta {
                    manager.onceSentEnvironment = meta.sentEnvironment
                }
                manager.saveResponse(response.flatValue())
            }
            return response.value ?? old.value
        } catch {
            throw error.asAdaptyError ?? .syncProfileFailed(unknownError: error)
        }
    }
}
