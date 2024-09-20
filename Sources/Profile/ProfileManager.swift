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
    var onceSentEnvironment: SendedEnvironment
    var isActive: Bool = true

    let storage: ProfileStorage
    let paywallsCache: PaywallsCache
    let productStatesCache: ProductStatesCache

    init(
        storage: ProfileStorage,
        paywallStorage: PaywallsStorage,
        productStorage: BackendProductStatesStorage,
        profile: VH<AdaptyProfile>,
        sendedEnvironment: SendedEnvironment
    ) {
        profileId = profile.value.profileId
        self.profile = profile
        self.onceSentEnvironment = sendedEnvironment

        self.storage = storage
        paywallsCache = PaywallsCache(storage: paywallStorage, profileId: profileId)
        productStatesCache = ProductStatesCache(storage: productStorage)

        Task { [weak self] in
            try? Adapty.sdk().updateASATokenIfNeed(for: profile)

            if sendedEnvironment == .dont {
                _ = try? await self?.getProfile()
            } else {
                self?.syncTransactionsIfNeed()
            }

            Adapty.callDelegate { $0.didLoadLatestProfile(profile.value) }
        }
    }
}

extension ProfileManager {
    nonisolated func syncTransactionsIfNeed() { // TODO: ???
        Task { [weak self] in
            guard let sdk = try? Adapty.sdk(),
                  let self,
                  !self.storage.syncedTransactions
            else { return }

            _ = try? await sdk.syncTransactions(refreshReceiptIfEmpty: true)
        }
    }

    func updateProfileParameters(_ params: AdaptyProfileParameters) async throws -> AdaptyProfile {
        try await syncProfile(params: params)
    }

    func getProfile() async throws -> AdaptyProfile {
        syncTransactionsIfNeed()
        return await (try? syncProfile(params: nil)) ?? profile.value
    }

    private func syncProfile(params: AdaptyProfileParameters?) async throws -> AdaptyProfile {
        let environmentMeta = onceSentEnvironment.getValueIfNeedSend(
            analyticsDisabled: (params?.analyticsDisabled ?? false) || storage.externalAnalyticsDisabled
        )

        do {
            let old = profile

            let response = try await Adapty.sdk().httpSession.performSyncProfileRequest(
                profileId: profileId,
                parameters: params,
                environmentMeta: environmentMeta,
                responseHash: old.hash
            )

            guard isActive else { // TODO: ??
                throw AdaptyError.profileWasChanged()
            }

            if let environmentMeta {
                onceSentEnvironment = environmentMeta.idfa == nil
                    ? .withoutIdfa
                    : .withIdfa
            }

            saveResponse(response.flatValue())
            return response.value ?? old.value
        } catch {
            throw error.asAdaptyError ?? .syncProfileFailed(unknownError: error)
        }
    }

    func saveResponse(_ newProfile: VH<AdaptyProfile>?) {
        guard isActive,
              let newProfile,
              profile.value.profileId == newProfile.value.profileId,
              profile.value.version <= newProfile.value.version
        else { return }

        if let oldHash = profile.hash,
           let newHash = newProfile.hash,
           oldHash == newHash { return }

        profile = newProfile
        storage.setProfile(newProfile)

        Adapty.callDelegate { $0.didLoadLatestProfile(newProfile.value) }
    }
}
