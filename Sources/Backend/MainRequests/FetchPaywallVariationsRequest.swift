//
//  FetchPaywallVariationsRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.03.2024
//

import Foundation

private struct FetchPaywallVariationsRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = AdaptyPaywallChosen

    let endpoint: HTTPEndpoint
    let headers: HTTPHeaders
    let stamp = Log.stamp

    let profileId: String
    let cached: AdaptyPaywall?
    let queryItems: QueryItems

    func decodeDataResponse(
        _ response: HTTPDataResponse,
        withConfiguration configuration: HTTPCodableConfiguration?
    ) throws -> Response {
        try Self.decodeDataResponse(
            response,
            withConfiguration: configuration,
            withProfileId: profileId,
            withCachedPaywall: cached
        )
    }

    init(apiKeyPrefix: String, profileId: String, placementId: String, locale: AdaptyLocale, md5Hash: String, segmentId: String, cached: AdaptyPaywall?, disableServerCache: Bool) {
        self.profileId = profileId
        self.cached = cached

        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/paywall/variations/\(placementId)/\(md5Hash)/"
        )

        headers = HTTPHeaders()
            .setPaywallLocale(locale)
            .setBackendProfileId(profileId)
            .setVisualBuilderVersion(AdaptyUICore.builderVersion)
            .setVisualBuilderConfigurationFormatVersion(AdaptyUICore.configurationFormatVersion)
            .setSegmentId(segmentId)

        queryItems = QueryItems().setDisableServerCache(disableServerCache)
    }
}

extension HTTPRequestWithDecodableResponse where ResponseBody == AdaptyPaywallChosen {
    @inlinable
    static func decodeDataResponse(
        _ response: HTTPDataResponse,
        withConfiguration configuration: HTTPCodableConfiguration?,
        withProfileId profileId: String,
        withCachedPaywall cached: AdaptyPaywall?
    ) throws -> HTTPResponse<AdaptyPaywallChosen> {
        let jsonDecoder = JSONDecoder()
        configuration?.configure(jsonDecoder: jsonDecoder)
        jsonDecoder.setProfileId(profileId)

        let version: Int64 = try jsonDecoder.decode(
            Backend.Response.ValueOfMeta<AdaptyPaywallChosen.Meta>.self,
            responseBody: response.body
        ).meta.version

        let body: AdaptyPaywallChosen =
            if let cached, cached.version > version {
                AdaptyPaywallChosen(
                    value: cached,
                    kind: .restore
                )
            } else {
                try jsonDecoder.decode(
                    Backend.Response.ValueOfData<AdaptyPaywallChosen>.self,
                    responseBody: response.body
                ).value.replaceAdaptyPaywall(version: version)
            }

        return response.replaceBody(body)
    }
}

extension Backend.MainExecutor {
    func fetchPaywallVariations(
        apiKeyPrefix: String,
        profileId: String,
        placementId: String,
        locale: AdaptyLocale,
        segmentId: String,
        cached: AdaptyPaywall?,
        disableServerCache: Bool
    ) async throws -> AdaptyPaywallChosen {
        let md5Hash = "{\"builder_version\":\"\(AdaptyUICore.builderVersion)\",\"locale\":\"\(locale.id.lowercased())\",\"segment_hash\":\"\(segmentId)\",\"store\":\"app_store\"}".md5.hexString

        let request = FetchPaywallVariationsRequest(
            apiKeyPrefix: apiKeyPrefix,
            profileId: profileId,
            placementId: placementId,
            locale: locale,
            md5Hash: md5Hash,
            segmentId: segmentId,
            cached: cached,
            disableServerCache: disableServerCache
        )

        let response = try await perform(
            request,
            requestName: .fetchPaywallVariations,
            logParams: [
                "api_prefix": apiKeyPrefix,
                "placement_id": placementId,
                "locale": locale,
                "segment_id": segmentId,
                "builder_version": AdaptyUICore.builderVersion,
                "builder_config_format_version": AdaptyUICore.configurationFormatVersion,
                "md5": md5Hash,
                "disable_server_cache": disableServerCache,
            ]
        )

        return response.body
    }
}
