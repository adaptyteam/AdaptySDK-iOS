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

    let storage: ProfileStorage
    let paywallsCache: PaywallsCache
    let productStatesCache: ProductStatesCache

    @AdaptyActor
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
            try? Adapty.sdk.updateASATokenIfNeed(for: profile)

            if sendedEnvironment == .dont {
                _ = await self?.getProfile()
            } else {
                self?.syncTransactionsIfNeed()
            }

            Adapty.callDelegate { $0.didLoadLatestProfile(profile.value) }
        }
    }
}

extension ProfileManager {
    nonisolated func syncTransactionsIfNeed() { // TODO: extruct this code from ProfileManager
        Task { [weak self] in
            guard let sdk = try? await Adapty.sdk,
                  let self,
                  !self.storage.syncedTransactions
            else { return }

            _ = try? await sdk.syncTransactions(refreshReceiptIfEmpty: true)
        }
    }

    func updateProfile(params: AdaptyProfileParameters) async throws -> AdaptyProfile {
        try await syncProfile(params: params)
    }

    func getProfile() async -> AdaptyProfile {
        syncTransactionsIfNeed()
        return await (try? syncProfile(params: nil)) ?? profile.value
    }

    private func syncProfile(params: AdaptyProfileParameters?) async throws -> AdaptyProfile {
        if let analyticsDisabled = params?.analyticsDisabled {
            storage.setExternalAnalyticsDisabled(analyticsDisabled)
        }

        let meta = await onceSentEnvironment.getValueIfNeedSend(
            analyticsDisabled: (params?.analyticsDisabled ?? false) || storage.externalAnalyticsDisabled
        )

        return try await Adapty.sdk.syncProfile(
            profile: profile,
            params: params,
            environmentMeta: meta
        )
    }

    func saveResponse(_ newProfile: VH<AdaptyProfile>?) {
        guard let newProfile,
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
                    manager.onceSentEnvironment = meta.idfa == nil
                        ? .withoutIdfa
                        : .withIdfa
                }
                manager.saveResponse(response.flatValue())
            }
            return response.value ?? old.value
        } catch {
            throw error.asAdaptyError ?? .syncProfileFailed(unknownError: error)
        }
    }
}
