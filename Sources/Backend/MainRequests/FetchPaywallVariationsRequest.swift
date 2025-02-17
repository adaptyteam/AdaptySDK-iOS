//
//  FetchPaywallVariationsRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.03.2024
//

import Foundation

private struct FetchPaywallVariationsRequest: HTTPRequest {
    let endpoint: HTTPEndpoint
    let headers: HTTPHeaders
    let stamp = Log.stamp

    let queryItems: QueryItems

    init(apiKeyPrefix: String, profileId: String, placementId: String, locale: AdaptyLocale, md5Hash: String, segmentId: String, crossPlacementEligible: Bool, disableServerCache: Bool) {
        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/paywall/variations/\(placementId)/\(md5Hash)/"
        )

        headers = HTTPHeaders()
            .setPaywallLocale(locale)
            .setBackendProfileId(profileId)
            .setVisualBuilderVersion(AdaptyViewConfiguration.builderVersion)
            .setVisualBuilderConfigurationFormatVersion(AdaptyViewConfiguration.formatVersion)
            .setCrossPlacementEligibility(crossPlacementEligible)
            .setSegmentId(segmentId)

        queryItems = QueryItems().setDisableServerCache(disableServerCache)
    }
}

extension AdaptyPaywallChosen {
    @inlinable
    static func decodeResponse(
        _ response: HTTPDataResponse,
        withConfiguration configuration: HTTPCodableConfiguration?,
        withProfileId profileId: String,
        withCachedPaywall cached: AdaptyPaywall?,
        crossPlacementEligible: Bool
    ) async throws -> HTTPResponse<AdaptyPaywallChosen> {
        let jsonDecoder = JSONDecoder()
        configuration?.configure(jsonDecoder: jsonDecoder)

        let version: Int64 = try jsonDecoder.decode(
            Backend.Response.ValueOfMeta<AdaptyPaywallVariations.Meta>.self,
            responseBody: response.body
        ).meta.version

        if let cached, cached.version > version {
            return response.replaceBody(AdaptyPaywallChosen.restored(cached))
        }

        let paywallVariationId: String
        if crossPlacementEligible {
            paywallVariationId = "not implimented"
        } else {
            jsonDecoder.setProfileId(profileId)

            paywallVariationId = try jsonDecoder.decode(
                Backend.Response.ValueOfData<AdaptyPaywallVariations.Draw>.self,
                responseBody: response.body
            ).value.variationId
        }

        jsonDecoder.setPaywallVariationId(paywallVariationId)

        guard let paywall = try jsonDecoder.decode(
            Backend.Response.ValueOfData<AdaptyPaywallVariations.Value>.self,
            responseBody: response.body
        ).value.paywall else {
            throw ResponseDecodingError.notFoundVariationId
        }

        return response.replaceBody(AdaptyPaywallChosen.draw(profileId, paywall))
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
        crossPlacementEligible: Bool,
        disableServerCache: Bool
    ) async throws -> AdaptyPaywallChosen {
        let md5Hash = "{\"builder_version\":\"\(AdaptyViewConfiguration.builderVersion)\",\(crossPlacementEligible ? "\"cross_placement_eligibility\":true," : "")\"locale\":\"\(locale.id.lowercased())\",\"segment_hash\":\"\(segmentId)\",\"store\":\"app_store\"}".md5.hexString

        let request = FetchPaywallVariationsRequest(
            apiKeyPrefix: apiKeyPrefix,
            profileId: profileId,
            placementId: placementId,
            locale: locale,
            md5Hash: md5Hash,
            segmentId: segmentId,
            crossPlacementEligible: crossPlacementEligible,
            disableServerCache: disableServerCache
        )

        let configuration = session.configuration as? HTTPCodableConfiguration

        let response: HTTPResponse<AdaptyPaywallChosen> = try await perform(
            request,
            requestName: .fetchPaywallVariations,
            logParams: [
                "api_prefix": apiKeyPrefix,
                "placement_id": placementId,
                "locale": locale,
                "segment_id": segmentId,
                "builder_version": AdaptyViewConfiguration.builderVersion,
                "builder_config_format_version": AdaptyViewConfiguration.formatVersion,
                "md5": md5Hash,
                "cross_placement_eligibility": crossPlacementEligible,
                "disable_server_cache": disableServerCache,
            ]
        ) { @Sendable response in
            try await AdaptyPaywallChosen.decodeResponse(
                response,
                withConfiguration: configuration,
                withProfileId: profileId,
                withCachedPaywall: cached,
                crossPlacementEligible: crossPlacementEligible
            )
        }

        return response.body
    }
}
