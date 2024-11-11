//
//  Request.GetPaywall.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct GetPaywall: AdaptyPluginRequest {
        static let method = Method.getPaywall

        let placementId: String
        let locale: String?
        let fetchPolicy: AdaptyPaywall.FetchPolicy?
        let loadTimeout: TimeInterval?

        init(from jsonDictionary: AdaptyJsonDictionary) throws {
            try self.init(
                placementId: jsonDictionary
                    .value(String.self, forKey: CodingKeys.placementId),
                locale: jsonDictionary.valueIfPresent(String.self, forKey: CodingKeys.locale),
                fetchPolicy: jsonDictionary.valueIfPresent(forKey: CodingKeys.fetchPolicy),
                loadTimeout: jsonDictionary.valueIfPresent(Double.self, forKey: CodingKeys.loadTimeout)
            )
        }

        init(
            placementId: String,
            locale: String?,
            fetchPolicy: KeyValue?,
            loadTimeout: Double?
        ) throws {
            self.placementId = placementId
            self.locale = locale
            self.fetchPolicy = try fetchPolicy?.decode(AdaptyPaywall.FetchPolicy.self)
            self.loadTimeout = loadTimeout
        }

        func execute() async throws -> AdaptyJsonData {
            let paywall = try await Adapty.getPaywall(
                placementId: placementId,
                locale: locale,
                fetchPolicy: fetchPolicy ?? AdaptyPaywall.FetchPolicy.default,
                loadTimeout: loadTimeout ?? Adapty.defaultLoadPaywallTimeout
            )
            return .success(paywall)
        }
    }
}

private enum CodingKeys: String, CodingKey {
    case placementId = "placement_id"
    case locale
    case fetchPolicy = "fetch_policy"
    case loadTimeout = "load_timeout"
}

public extension AdaptyPlugin {
    @objc static func getPaywall(
        placementId: String,
        locale: String,
        fetchPolicy: String,
        loadTimeout: Double,
        _ completion: @escaping AdaptyJsonDataCompletion
    ) {
        withCompletion(completion) {
            await Request.GetPaywall.execute {
                try Request.GetPaywall(
                    placementId: placementId,
                    locale: locale,
                    fetchPolicy: .init(key: CodingKeys.fetchPolicy, value: fetchPolicy),
                    loadTimeout: loadTimeout
                )
            }
        }
    }
}
