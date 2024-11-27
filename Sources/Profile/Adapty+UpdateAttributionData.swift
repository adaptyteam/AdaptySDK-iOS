//
//  Adapty+UpdateAttribution.swift
//  AdaptySDK
//
//  Created by Andrey Kyashkin on 28.10.2019.
//

import Foundation

public extension Adapty {
    /// To set attribution data for the profile, use this method.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/docs/attribution-integration)
    ///
    /// - Parameter attribution: a dictionary containing attribution (conversion) data.
    /// - Parameter source: a source of attribution. The allowed values are: `.appsflyer`, `.adjust`, `.branch`, `.custom`.
    /// - Parameter networkUserId: a string profile's identifier from the attribution service.
    nonisolated static func updateAttribution(
        _ attribution: [AnyHashable: Any],
        source: AdaptyAttributionSource,
        networkUserId: String? = nil
    ) async throws {
        let attributionJson: String
        do {
            let data = try JSONSerialization.data(withJSONObject: attribution)
            attributionJson = String(decoding: data, as: UTF8.self)
        } catch {
            throw AdaptyError.wrongAttributeData(error)
        }
        
        if source == .appsflyer {
            assert(networkUserId != nil, "`networkUserId` is required for AppsFlyer attribution, otherwise we won't be able to send specific events. You can get it by accessing `AppsFlyerLib.shared().getAppsFlyerUID()` or in a similar way according to the official SDK.")
        }
        let logParams: EventParameters = [
            "source": source.rawValue,
            "has_network_user_id": networkUserId != nil,
        ]
        
        try await withActivatedSDK(methodName: .updateAttribution, logParams: logParams) { sdk in
            
            let profileId = sdk.profileStorage.profileId
            
            if let networkUserId {
                try await sdk.setIntegrationIdentifier(
                    profileId: profileId,
                    keyValues: ["appsflyer_id": networkUserId]
                )
            }
            
            try await sdk.setAttributionData(
                profileId: profileId,
                source: source.rawValue,
                attributionJson: attributionJson
            )
        }
    }
        
    nonisolated static func updateAttribution(
        _ attribution: [AnyHashable: Any],
        source: String
    ) async throws {
        let attributionJson: String
        do {
            let data = try JSONSerialization.data(withJSONObject: attribution)
            attributionJson = String(decoding: data, as: UTF8.self)
        } catch {
            throw AdaptyError.wrongAttributeData(error)
        }
            
        try await updateAttribution(
            attributionJson,
            source: source
        )
    }

    nonisolated static func updateAttribution(
        _ attributionJson: String,
        source: String
    ) async throws {
        let logParams: EventParameters = [
            "source": source,
        ]
            
        try await withActivatedSDK(methodName: .updateAttributionData, logParams: logParams) { sdk in
                
            try await sdk.setAttributionData(
                profileId: sdk.profileStorage.profileId,
                source: source,
                attributionJson: attributionJson
            )
        }
    }

    fileprivate func setAttributionData(
        profileId: String,
        source: String,
        attributionJson: String
    ) async throws {
        let oldResponseHash = profileManager?.profile.hash

        do {
            let response = try await httpSession.setAttributionData(
                profileId: profileId,
                source: source,
                attributionJson: attributionJson,
                responseHash: oldResponseHash
            )

            if let profile = response.flatValue() {
                profileManager?.saveResponse(profile)
            }

        } catch {
            throw error.asAdaptyError ?? .updateAttributionFaild(unknownError: error)
        }
    }
}
