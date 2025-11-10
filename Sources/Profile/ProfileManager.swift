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

    var currentProfile: AdaptyProfile { cachedProfile.value }
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

        Task { @AdaptyActor [weak self] in
            guard let sdk = Adapty.optionalSDK else { return }
            sdk.updateASATokenIfNeed(for: profile)

            let currentProfile = await sdk.profileWithOfflineAccessLevels(profile.value)
            Adapty.callDelegate { $0.didLoadLatestProfile(currentProfile) }

            if sentEnvironment == .none {
                _ = await self?.fetchProfile()
            } else {
                try? await sdk.syncTransactionHistory(for: profile.userId)
            }
        }
    }

    fileprivate func saveProfileAndStartNotifyTask(
        _ newProfile: VH<AdaptyProfile>
    ) throws(WrongProfileIdError) -> Task<AdaptyProfile, Never>? {
        guard newProfile.isEqualProfileId(userId) else { throw WrongProfileIdError() }

        if newProfile.IsNotEqualHash(cachedProfile),
           newProfile.isNewerOrEqualVersion(cachedProfile)
        {
            cachedProfile = newProfile
        }

        do {
            try storage.updateProfile(newProfile)
        } catch {
            return nil
        }

        return Task {
            await notifyProfileDidChanged()
        }
    }

    fileprivate func notifyProfileDidChanged() async -> AdaptyProfile {
        let profile = await profileWithOfflineAccessLevels
        Adapty.callDelegate { $0.didLoadLatestProfile(profile) }
        return profile
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
            try? storage.setExternalAnalyticsDisabled(analyticsDisabled, for: userId)
        }
        return try await syncProfile(params: params)
    }

    func fetchProfile() async -> AdaptyProfile {
        if let profile = try? await syncProfile(params: nil) {
            return profile
        }
        return await profileWithOfflineAccessLevels
    }

    private func syncProfile(
        params: AdaptyProfileParameters?
    ) async throws(AdaptyError) -> AdaptyProfile {
        let analyticsDisabled = (params?.analyticsDisabled ?? false)
            || ((try? storage.externalAnalyticsDisabled(for: userId)) ?? false)
        let meta = await onceSentEnvironment.getValueIfNeedSend(analyticsDisabled: analyticsDisabled)

        let httpSession = try await Adapty.activatedSDK.httpSession
        let old = cachedProfile
        let response: VH<AdaptyProfile>?

        do throws(HTTPError) {
            if params == nil, meta == nil {
                Task { @AdaptyActor in
                    try? await Adapty.optionalSDK?.syncTransactionHistory(for: userId)
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
           let profile = try? await saveProfileAndStartNotifyTask(response)?.value
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
        _ = try? profileManager?.saveProfileAndStartNotifyTask(response)
    }

    /// Handles the server profile response.
    /// If the profile is newer, it will be persisted and delivered to the delegate.
    /// - Parameter response: Server response containing a profile. User ID comparison is not required.
    /// - Returns: if the manager is working with the same user, returns Task
    func handleTransactionResponse(_ response: VH<AdaptyProfile>) {
        try? profileStorage.setSyncedTransactionsHistory(true, for: response.userId)
        _ = try? profileManager?.saveProfileAndStartNotifyTask(response)
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    func recalculateOfflineAccessLevels() async -> AdaptyProfile {
        await (transactionManager as? SK2TransactionManager)?.clearCache()

        if let manger = profileManager {
            return await manger.notifyProfileDidChanged()
        }

        let manger = offlineProfileManager ?? OfflineProfileManager(userId: profileStorage.userId)
        return await profileWithOfflineAccessLevels(manger.currentProfile)
    }

    func syncTransactionHistory(for userId: AdaptyUserId, forceSync: Bool = false) async throws(AdaptyError) {
        try await transactionManager.syncUnfinishedTransactions()

        guard let syncedTransactionsHistory = try? profileStorage.syncedTransactionsHistory(for: userId) else {
            return
        }

        guard forceSync || !syncedTransactionsHistory else { return }
        try await transactionManager.syncTransactionHistory(for: userId)
    }

    func profileWithOfflineAccessLevels(_ serverProfile: AdaptyProfile) async -> AdaptyProfile {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *),
              let transactionManager = transactionManager as? SK2TransactionManager,
              let productsManager = productsManager as? SK2ProductsManager
        else {
            return serverProfile
        }
        var verifiedCurrentEntitlements = await transactionManager.getVerifiedCurrentEntitlements()

        if await !transactionManager.hasUnfinishedTransactions {
            verifiedCurrentEntitlements = verifiedCurrentEntitlements.filter {
                $0.unfEnvironment == SK2Transaction.xcodeEnvironment
            }
        }

        guard !verifiedCurrentEntitlements.isEmpty else { return serverProfile }

        return await serverProfile.added(
            transactions: verifiedCurrentEntitlements,
            productManager: productsManager
        )
    }
}
