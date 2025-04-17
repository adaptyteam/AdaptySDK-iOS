//
//  FetchPlacementVariationsRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.03.2024
//

import Foundation

private struct FetchPlacementVariationsRequest: HTTPRequest {
    let endpoint: HTTPEndpoint
    let headers: HTTPHeaders
    let stamp = Log.stamp

    let queryItems: QueryItems

    init(
        endpoint: HTTPEndpoint,
        profileId: String,
        locale: AdaptyLocale,
        segmentId: String,
        crossPlacementEligible: Bool,
        disableServerCache: Bool
    ) {
        self.endpoint = endpoint

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

extension AdaptyPlacementChosen {
    typealias VariationIdResolver = @Sendable (_ placementId: String, AdaptyPlacement.Draw<Content>) async throws -> String

    @inlinable
    static func decodePlacementVariationsResponse(
        _ response: HTTPDataResponse,
        withConfiguration configuration: HTTPCodableConfiguration?,
        withProfileId profileId: String,
        withPlacemantId placementId: String,
        withCached cached: Content?,
        variationIdResolver: VariationIdResolver?
    ) async throws -> HTTPResponse<AdaptyPlacementChosen> {
        let jsonDecoder = JSONDecoder()
        configuration?.configure(jsonDecoder: jsonDecoder)

        let placement = try jsonDecoder.decode(
            Backend.Response.Meta<AdaptyPlacement>.self,
            responseBody: response.body
        ).value

        if let cached, cached.placement.version > placement.version {
            return response.replaceBody(AdaptyPlacementChosen.restore(cached))
        }

        jsonDecoder.setPlacement(placement)
        jsonDecoder.setProfileId(profileId)

        let draw = try jsonDecoder.decode(
            Backend.Response.Data<AdaptyPlacement.Draw<Content>>.self,
            responseBody: response.body
        ).value

        guard let variationId = try await variationIdResolver?(placementId, draw),
              variationId != draw.content.variationId
        else {
            if variationIdResolver == nil {
                Log.crossAB.verbose("AB-test placementId = \(placementId), variationId = \(draw.content.variationId) DRAW")
            }
            return response.replaceBody(AdaptyPlacementChosen.draw(draw))
        }

        jsonDecoder.setPlacementVariationId(variationId)

        let variation = try jsonDecoder.decode(
            Backend.Response.Data<AdaptyPlacement.Draw<Content>>.self,
            responseBody: response.body
        ).value

        return response.replaceBody(AdaptyPlacementChosen.draw(variation))
    }
}

extension Backend.MainExecutor {
    func fetchPlacementVariations<Content: AdaptyPlacementContent>(
        apiKeyPrefix: String,
        profileId: String,
        placementId: String,
        locale: AdaptyLocale,
        segmentId: String,
        cached: Content?,
        crossPlacementEligible: Bool,
        variationIdResolver: AdaptyPlacementChosen<Content>.VariationIdResolver?,
        disableServerCache: Bool
    ) async throws -> AdaptyPlacementChosen<Content> {
        let endpoint: HTTPEndpoint
        let requestName: APIRequestName
        let md5Hash: String

        if Content.self == AdaptyPaywall.self {
            md5Hash = "{\"builder_version\":\"\(AdaptyViewConfiguration.builderVersion)\",\(crossPlacementEligible ? "\"cross_placement_eligibility\":true," : "")\"locale\":\"\(locale.id.lowercased())\",\"segment_hash\":\"\(segmentId)\",\"store\":\"app_store\"}".md5.hexString

            endpoint = HTTPEndpoint(
                method: .get,
                path: "/sdk/in-apps/\(apiKeyPrefix)/paywall/variations/\(placementId)/\(md5Hash)/"
            )
            requestName = .fetchPaywallVariations
        } else {
            md5Hash = "{\"locale\":\"\(locale.id.lowercased())\",\"segment_hash\":\"\(segmentId)\"}".md5.hexString

            endpoint = HTTPEndpoint(
                method: .get,
                path: "/sdk/in-apps/\(apiKeyPrefix)/onboarding/variations/\(placementId)/\(md5Hash)/"
            )
            requestName = .fetchOnboardingVariations
        }

        let request = FetchPlacementVariationsRequest(
            endpoint: endpoint,
            profileId: profileId,
            locale: locale,
            segmentId: segmentId,
            crossPlacementEligible: crossPlacementEligible,
            disableServerCache: disableServerCache
        )

        let configuration = session.configuration as? HTTPCodableConfiguration

        let response: HTTPResponse<AdaptyPlacementChosen> = try await perform(
            request,
            requestName: requestName,
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
            try await AdaptyPlacementChosen.decodePlacementVariationsResponse(
                response,
                withConfiguration: configuration,
                withProfileId: profileId,
                withPlacemantId: placementId,
                withCached: cached,
                variationIdResolver: variationIdResolver
            )
        }

        return response.body
    }
}
