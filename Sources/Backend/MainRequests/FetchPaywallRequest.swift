//
//  FetchPaywallRequest.swift
//  Adapty
//
//  Created by Aleksei Valiano on 23.01.2025.
//

import Foundation

private struct FetchPaywallRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = AdaptyPaywall

    let endpoint: HTTPEndpoint
    let headers: HTTPHeaders
    let queryItems: QueryItems
    let stamp = Log.stamp

    init(
        apiKeyPrefix: String,
        profileId: String,
        placementId: String,
        paywallVariationId: String,
        locale: AdaptyLocale,
        md5Hash: String,
        disableServerCache: Bool
    ) {
        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/paywall/variations/\(placementId)/\(md5Hash)/\(paywallVariationId)/"
        )

        headers = HTTPHeaders()
            .setPaywallLocale(locale)
            .setBackendProfileId(profileId)
            .setVisualBuilderVersion(AdaptyViewConfiguration.builderVersion)
            .setVisualBuilderConfigurationFormatVersion(AdaptyViewConfiguration.formatVersion)

        queryItems = QueryItems().setDisableServerCache(disableServerCache)
    }
}

extension Backend.MainExecutor {
    func fetchPaywall(
        apiKeyPrefix: String,
        profileId: String,
        placementId: String,
        paywallVariationId: String,
        locale: AdaptyLocale,
        cached: AdaptyPaywall?,
        disableServerCache: Bool
    ) async throws -> AdaptyPaywallChosen {
        let md5Hash = "{\"builder_version\":\"\(AdaptyViewConfiguration.builderVersion)\",\"locale\":\"\(locale.id.lowercased())\",\"store\":\"app_store\"}".md5.hexString

        let request = FetchPaywallRequest(
            apiKeyPrefix: apiKeyPrefix,
            profileId: profileId,
            placementId: placementId,
            paywallVariationId: paywallVariationId,
            locale: locale,
            md5Hash: md5Hash,
            disableServerCache: disableServerCache
        )

        let response = try await perform(
            request,
            requestName: .fetchPaywall,
            logParams: [
                "api_prefix": apiKeyPrefix,
                "placement_id": placementId,
                "variation_id": paywallVariationId,
                "locale": locale,
                "builder_version": AdaptyViewConfiguration.builderVersion,
                "builder_config_format_version": AdaptyViewConfiguration.formatVersion,
                "md5": md5Hash,
                "disable_server_cache": disableServerCache,
            ]
        )

        return AdaptyPaywallChosen.draw(profileId, response.body)
    }
}
