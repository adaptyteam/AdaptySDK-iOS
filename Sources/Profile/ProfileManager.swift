//
//  ProfileManager.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.10.2022.
//

import Foundation

@AdaptyActor
final class ProfileManager {
    var userId: AdaptyUserId { profile.userId }
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
        let userId = profile.userId
        self.profile = profile
        self.onceSentEnvironment = sentEnvironment
        self.storage = storage

        Task { [weak self] in
            Adapty.optionalSDK?.updateASATokenIfNeed(for: profile)

            if sentEnvironment == .none {
                _ = await self?.getProfile()
            } else {
                self?.syncTransactionsIfNeed(for: userId)
            }

            Adapty.callDelegate { $0.didLoadLatestProfile(profile.value) }
        }
    }
}

extension ProfileManager {
    nonisolated func syncTransactionsIfNeed(for userId: AdaptyUserId) { // TODO: extract this code from ProfileManager
        Task { @AdaptyActor [weak self] in
            guard let sdk = Adapty.optionalSDK,
                  let self,
                  !self.storage.syncedTransactions
            else { return }

            try? await sdk.syncTransactions(for: userId)
        }
    }

    func updateProfile(params: AdaptyProfileParameters) async throws(AdaptyError) -> AdaptyProfile {
        try await syncProfile(params: params)
    }

    func getProfile() async -> AdaptyProfile {
        syncTransactionsIfNeed(for: userId)
        return await (try? syncProfile(params: nil)) ?? profile.value
    }

    private func syncProfile(params: AdaptyProfileParameters?) async throws(AdaptyError) -> AdaptyProfile {
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
              newProfile.isEqualProfileId(profile),
              !newProfile.hash.nonOptionalIsEqual(profile.hash),
              newProfile.value.isNewerOrEqualVersion(profile.value)
        else { return }

        profile = newProfile
        storage.setProfile(newProfile)

        Adapty.callDelegate { $0.didLoadLatestProfile(newProfile.value) }
    }
}

extension Adapty {
    func syncTransactions(for userId: AdaptyUserId) async throws(AdaptyError) {
        let response = try await transactionManager.syncTransactions(for: userId)

        if profileStorage.isEqualProfileId(userId) {
            profileStorage.setSyncedTransactions(true)
        }
        profileManager?.saveResponse(response)
    }

    func saveResponse(_ newProfile: VH<AdaptyProfile>, syncedTransaction: Bool = false) {
        if syncedTransaction, newProfile.isEqualProfileId(profileStorage) {
            profileStorage.setSyncedTransactions(true)
        }
        profileManager?.saveResponse(newProfile)
    }
}

private extension Adapty {
    func syncProfile(profile old: VH<AdaptyProfile>, params: AdaptyProfileParameters?, environmentMeta meta: Environment.Meta?) async throws(AdaptyError) -> AdaptyProfile {
        let response: VH<AdaptyProfile?>
        do {
            response = try await httpSession.syncProfile(
                userId: old.userId,
                parameters: params,
                environmentMeta: meta,
                responseHash: old.hash
            )
        } catch {
            throw error.asAdaptyError
        }

        if let manager = try profileManager(withProfileId: old.userId) {
            if let meta {
                manager.onceSentEnvironment = meta.sentEnvironment
            }
            manager.saveResponse(response.flatValue())
        }
        return response.value ?? old.value
    }
}
