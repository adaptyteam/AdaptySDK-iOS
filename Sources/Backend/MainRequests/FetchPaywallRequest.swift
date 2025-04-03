//
//  FetchPaywallRequest.swift
//  Adapty
//
//  Created by Aleksei Valiano on 23.01.2025.
//

import Foundation

private struct FetchPaywallRequest: HTTPRequest {
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

extension AdaptyPaywallChosen {
    @inlinable
    static func decodePaywallResponse(
        _ response: HTTPDataResponse,
        withConfiguration configuration: HTTPCodableConfiguration?,
        withProfileId profileId: String,
        withPlacemantId placementId: String,
        withCachedPaywall cached: AdaptyPaywall? 
    ) async throws -> HTTPResponse<AdaptyPaywallChosen> {
        let jsonDecoder = JSONDecoder()
        configuration?.configure(jsonDecoder: jsonDecoder)
        jsonDecoder.setProfileId(profileId)

        let version: Int64 = try jsonDecoder.decode(
            Backend.Response.ValueOfMeta<AdaptyPaywallVariations.Meta>.self,
            responseBody: response.body
        ).value.version

        if let cached, cached.version > version {
            return response.replaceBody(AdaptyPaywallChosen.restore(cached))
        }

        let draw = try jsonDecoder.decode(
            Backend.Response.ValueOfData<AdaptyPaywallVariations.Draw>.self,
            responseBody: response.body
        ).value.replacedPaywallVersion(version)

        return response.replaceBody(AdaptyPaywallChosen.draw(draw))
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

        let configuration = session.configuration as? HTTPCodableConfiguration

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
        ) { @Sendable response in
            try await AdaptyPaywallChosen.decodePaywallResponse(
                response,
                withConfiguration: configuration,
                withProfileId: profileId,
                withPlacemantId: placementId,
                withCachedPaywall: cached
            )
        }

        return response.body
    }
}
