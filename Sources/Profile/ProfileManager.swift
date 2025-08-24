//
//  ProfileManager.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.10.2022.
//

import Foundation

@AdaptyActor
final class ProfileManager {
    let userId: AdaptyUserId

    private var cachedProfile: VH<AdaptyProfile>
    private var onceSentEnvironment: SentEnvironment
    private let storage: ProfileStorage

    let crossPlacmentStorage = CrossPlacementStorage()
    let placementStorage = PlacementStorage()
    let backendIntroductoryOfferEligibilityStorage = BackendIntroductoryOfferEligibilityStorage()

    var isTestUser: Bool { cachedProfile.value.isTestUser }
    var segmentId: String { cachedProfile.value.segmentId }
    var lastResponseHash: String? { cachedProfile.hash }

    @AdaptyActor
    init(
        storage: ProfileStorage,
        profile: VH<AdaptyProfile>,
        sentEnvironment: SentEnvironment
    ) {
        self.userId = profile.userId
        self.cachedProfile = profile
        self.onceSentEnvironment = sentEnvironment
        self.storage = storage

        Task { [weak self] in
            guard let sdk = Adapty.optionalSDK else { return }
            sdk.updateASATokenIfNeed(for: profile)

            let currentProfile = await sdk.profileWithOfflineAccessLevels(profile.value)
            Adapty.callDelegate { $0.didLoadLatestProfile(currentProfile) }

            if sentEnvironment == .none {
                _ = await self?.fetchProfile()
            } else {
                try? await sdk.syncTransactionsIfNeed(for: profile.userId)
            }
        }
    }

    func handleTransactionResponse(_ response: VH<AdaptyProfile>) async -> AdaptyProfile? {
        guard let task = saveProfileAndStartNotifyTask(response) else { return nil }
        storage.setSyncedTransactionsHistory(true)
        return await task.value
    }

    fileprivate func saveProfileAndStartNotifyTask(
        _ profile: VH<AdaptyProfile>
    ) -> Task<AdaptyProfile, Never>? {
        guard profile.isEqualProfileId(userId),
              profile.IsNotEqualHash(cachedProfile),
              profile.isNewerOrEqualVersion(cachedProfile)
        else { return nil }

        cachedProfile = profile
        guard storage.updateProfile(profile) else { return nil }
        return Task {
            let profile = await profileWithOfflineAccessLevels
            Adapty.callDelegate { $0.didLoadLatestProfile(profile) }
            return profile
        }
    }

    /// The  profile with offline access levels
    var profileWithOfflineAccessLevels: AdaptyProfile {
        get async {
            if let sdk = Adapty.optionalSDK {
                await sdk.profileWithOfflineAccessLevels(cachedProfile.value)
            } else {
                cachedProfile.value
            }
        }
    }

    func fetchSegmentId() async -> String {
        await fetchProfile().segmentId
    }

    func updateProfile(params: AdaptyProfileParameters) async throws(AdaptyError) -> AdaptyProfile {
        if let analyticsDisabled = params.analyticsDisabled {
            storage.setExternalAnalyticsDisabled(analyticsDisabled)
        }
        return try await syncProfile(params: params)
    }

    func fetchProfile(afterSyncTransactions: Bool = false) async -> AdaptyProfile {
        if let profile = try? await syncProfile(params: nil) {
            return profile
        }
        return await profileWithOfflineAccessLevels
    }

    private func syncProfile(
        params: AdaptyProfileParameters?
    ) async throws(AdaptyError) -> AdaptyProfile {
        let meta = await onceSentEnvironment.getValueIfNeedSend(
            analyticsDisabled: (params?.analyticsDisabled ?? false) || storage.externalAnalyticsDisabled
        )

        let httpSession = try await Adapty.activatedSDK.httpSession
        let old = cachedProfile
        let response: VH<AdaptyProfile>?

        do throws(HTTPError) {
            if params == nil, meta == nil {
                Task { @AdaptyActor in
                    try? await Adapty.optionalSDK?.syncTransactionsIfNeed(for: userId)
                }
                response = try await httpSession.fetchProfile(
                    userId: old.userId,
                    responseHash: old.hash
                )
            } else {
                response = try await httpSession.updateProfile(
                    userId: old.userId,
                    parameters: params,
                    environmentMeta: meta,
                    responseHash: old.hash
                )

                if let meta {
                    onceSentEnvironment = meta.sentEnvironment
                }
            }
        } catch {
            throw error.asAdaptyError
        }

        if let response,
           let profile = await saveProfileAndStartNotifyTask(response)?.value
        {
            return profile
        }

        return await profileWithOfflineAccessLevels
    }
}

extension Adapty {
    /// Handles the server profile response.
    /// If the profile is newer, it will be persisted and delivered to the delegate.
    /// - Parameter response: Server response containing a profile. User ID comparison is not required.
    /// - Returns: if the manager is working with the same user, returns Task
    func handleProfileResponse(_ response: VH<AdaptyProfile>?) {
        guard let response else { return }
        _ = profileManager?.saveProfileAndStartNotifyTask(response)
    }

    /// Handles the server profile response.
    /// If the profile is newer, it will be persisted and delivered to the delegate.
    /// - Parameter response: Server response containing a profile. User ID comparison is not required.
    /// - Returns: if the manager is working with the same user, returns Task
    func handleTransactionResponse(_ response: VH<AdaptyProfile>?) {
        guard let response,
              let manager = profileManager,
              manager.saveProfileAndStartNotifyTask(response) != nil
        else { return }
        profileStorage.setSyncedTransactionsHistory(true)
    }

    func syncTransactionsIfNeed(for userId: AdaptyUserId) async throws(AdaptyError) {
        var needSync = !profileStorage.syncedTransactionsHistory
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
            
        }

        guard needSync else { return }
        try await syncTransactions(for: userId)
    }

    func syncTransactions(for userId: AdaptyUserId) async throws(AdaptyError) {
        let response = try await transactionSynchronizer.syncTransactions(for: userId)
        handleTransactionResponse(response)
    }

    func profileWithOfflineAccessLevels(_ serverProfile: AdaptyProfile) async -> AdaptyProfile {
        //   let observerMode = observerMode

        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) else {
            return serverProfile
        }
        // TODO: calculate
        return serverProfile
    }
}
