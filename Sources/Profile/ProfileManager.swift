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

            let currentProfile = sdk.profileWithOfflineAccessLevels(profile.value)
            Adapty.callDelegate { $0.didLoadLatestProfile(currentProfile) }

            if sentEnvironment == .none {
                _ = await self?.getProfile()
            } else {
                try? await sdk.syncTransactionsIfNeed(for: profile.userId)
            }
        }
    }

    /// Handles the server profile response.
    /// If the profile is newer, it will be persisted and delivered to the delegate.
    /// - Parameter response: Server response containing a profile. User ID comparison is not required.
    /// - Returns: The profile with offline access levels if the manager is working with the same user, otherwise `nil`
    @discardableResult
    func handleProfileResponse(_ response: VH<AdaptyProfile>?) -> AdaptyProfile? {
        guard let response,
              response.isEqualProfileId(userId),
              response.IsNotEqualHash(cachedProfile),
              response.isNewerOrEqualVersion(cachedProfile)
        else { return nil }

        cachedProfile = response
        guard storage.updateProfile(response) else { return nil }

        let profile = currentProfile
        Adapty.callDelegate { $0.didLoadLatestProfile(profile) }
        return profile
    }

    /// Handles the server transaction response and marks the transaction history as synced with the server.
    /// If the profile is newer, it will be persisted and delivered to the delegate.
    /// - Parameter response: Server response containing a profile. User ID comparison is not required.
    /// - Returns: The profile with offline access levels if the manager is working with the same user, otherwise `nil`
    @discardableResult
    func handleTransactionResponse(_ response: VH<AdaptyProfile>) -> AdaptyProfile? {
        guard let profile = handleProfileResponse(response) else {
            return nil
        }
        storage.setSyncedTransactionsHistory(true)
        return profile
    }

    /// The current profile with offline access levels
    fileprivate var currentProfile: AdaptyProfile {
        if let sdk = Adapty.optionalSDK {
            sdk.profileWithOfflineAccessLevels(cachedProfile.value)
        } else {
            cachedProfile.value
        }
    }

    /// The current profile with offline access levels, if available; otherwise `nil`.
    @inlinable
    var currentProfileWithOfflineAccessLevelsIfFeatureAvailable: AdaptyProfile? {
        guard let sdk = Adapty.optionalSDK, sdk.isAvailableOfflineAccessLevels else {
            return nil
        }
        return sdk.profileWithOfflineAccessLevels(cachedProfile.value)
    }

    func updateProfile(params: AdaptyProfileParameters) async throws(AdaptyError) -> AdaptyProfile {
        if let analyticsDisabled = params.analyticsDisabled {
            storage.setExternalAnalyticsDisabled(analyticsDisabled)
        }
        return try await syncProfile(params: params)
    }

    func getProfile() async -> AdaptyProfile {
        (try? await syncProfile(params: nil)) ?? currentProfile
    }

    private func syncProfile(params: AdaptyProfileParameters?) async throws(AdaptyError) -> AdaptyProfile {
        let meta = await onceSentEnvironment.getValueIfNeedSend(
            analyticsDisabled: (params?.analyticsDisabled ?? false) || storage.externalAnalyticsDisabled
        )

        let httpSession = try await Adapty.activatedSDK.httpSession
        let old = cachedProfile
        let response: VH<AdaptyProfile?>

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

        return handleProfileResponse(response.flatValue()) ?? currentProfile
    }
}

extension Adapty {
    func isNeedSyncTransactions(for userId: AdaptyUserId) -> Bool {
        var needSync = !profileStorage.syncedTransactionsHistory
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {}
        return needSync
    }

    func syncTransactionsIfNeed(for userId: AdaptyUserId) async throws(AdaptyError) {
        guard isNeedSyncTransactions(for: userId) else { return }
        let response = try await transactionManager.syncTransactions(for: userId)
        if let manager = profileManager, let response {
            _ = manager.handleTransactionResponse(response)
        }
    }

    func syncTransactions(for userId: AdaptyUserId) async throws(AdaptyError) -> AdaptyProfile? {
        let response = try await transactionManager.syncTransactions(for: userId)
        switch (profileManager, response) {
            case let (profileManager?, response?):
                return profileManager.handleTransactionResponse(response) ?? profileWithOfflineAccessLevels(response.value)
            case let (profileManager?, nil):
                return profileManager.currentProfile
            case let (nil, response?):
                return profileWithOfflineAccessLevels(response.value)
            default:
                return nil
        }
    }

    fileprivate var isAvailableOfflineAccessLevels: Bool {
        //   let observerMode = observerMode
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
            true
        } else {
            false
        }
    }

    func profileWithOfflineAccessLevels(_ serverProfile: AdaptyProfile) -> AdaptyProfile {
        guard isAvailableOfflineAccessLevels else {
            return serverProfile
        }
        // TODO: calculate
        return serverProfile
    }
}
