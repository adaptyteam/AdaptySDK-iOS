//
//  FetchPlacementVariationsRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.03.2024
//

import Foundation

private struct FetchPaywallVariationsRequest: HTTPRequest, BackendAPIRequestParameters {
    let endpoint: HTTPEndpoint
    let headers: HTTPHeaders
    let queryItems: QueryItems
    let stamp = Log.stamp

    let logName = APIRequestName.fetchPaywallVariations
    let logParams: EventParameters?

    init(
        apiKeyPrefix: String,
        profileId: String,
        placementId: String,
        locale: AdaptyLocale,
        segmentId: String,
        crossPlacementEligible: Bool,
        disableServerCache: Bool
    ) {
        let md5Hash = "{\"builder_version\":\"\(AdaptyViewConfiguration.builderVersion)\",\(crossPlacementEligible ? "\"cross_placement_eligibility\":true," : "")\"locale\":\"\(locale.id.lowercased())\",\"segment_hash\":\"\(segmentId)\",\"store\":\"app_store\"}".md5.hexString

        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/paywall/variations/\(placementId)/\(md5Hash)/"
        )

        headers = HTTPHeaders()
            .setPaywallLocale(locale)
            .setBackendProfileId(profileId)
            .setPaywallBuilderVersion(AdaptyViewConfiguration.builderVersion)
            .setPaywallBuilderConfigurationFormatVersion(AdaptyViewConfiguration.formatVersion)
            .setCrossPlacementEligibility(crossPlacementEligible)
            .setSegmentId(segmentId)

        queryItems = QueryItems().setDisableServerCache(disableServerCache)

        logParams = [
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
    }
}

private struct FetchOnboardingVariationsRequest: HTTPRequest, BackendAPIRequestParameters {
    let endpoint: HTTPEndpoint
    let headers: HTTPHeaders
    let queryItems: QueryItems
    let stamp = Log.stamp

    let logName = APIRequestName.fetchOnboardingVariations
    let logParams: EventParameters?

    init(
        apiKeyPrefix: String,
        profileId: String,
        placementId: String,
        locale: AdaptyLocale,
        segmentId: String,
        crossPlacementEligible: Bool,
        disableServerCache: Bool
    ) {
        let md5Hash = "{\"cross_placement_eligibility\":\(crossPlacementEligible ? "true" : "false"),\"locale\":\"\(locale.id.lowercased())\",\"segment_hash\":\"\(segmentId)\"}".md5.hexString

        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/onboarding/variations/\(placementId)/\(md5Hash)/"
        )

        headers = HTTPHeaders()
            .setOnboardingLocale(locale)
            .setBackendProfileId(profileId)
            .setOnboardingUIVersion(AdaptyOnboarding.ViewConfiguration.uiVersion)
            .setCrossPlacementEligibility(crossPlacementEligible)
            .setSegmentId(segmentId)

        queryItems = QueryItems().setDisableServerCache(disableServerCache)

        logParams = [
            "api_prefix": apiKeyPrefix,
            "placement_id": placementId,
            "locale": locale,
            "segment_id": segmentId,
            "md5": md5Hash,
            "cross_placement_eligibility": crossPlacementEligible,
            "disable_server_cache": disableServerCache,
        ]
    }
}

extension AdaptyPlacementChosen {
    typealias VariationIdResolver = @Sendable (_ placementId: String, AdaptyPlacement.Draw<Content>) async throws -> String

    @inlinable
    static func decodePlacementVariationsResponse(
        _ response: HTTPDataResponse,
        withConfiguration configuration: HTTPCodableConfiguration?,
        withProfileId profileId: String,
        withPlacementId placementId: String,
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
        let request: HTTPRequest & BackendAPIRequestParameters =
            if Content.self == AdaptyPaywall.self {
                FetchPaywallVariationsRequest(
                    apiKeyPrefix: apiKeyPrefix,
                    profileId: profileId,
                    placementId: placementId,
                    locale: locale,
                    segmentId: segmentId,
                    crossPlacementEligible: crossPlacementEligible,
                    disableServerCache: disableServerCache
                )

            } else {
                FetchOnboardingVariationsRequest(
                    apiKeyPrefix: apiKeyPrefix,
                    profileId: profileId,
                    placementId: placementId,
                    locale: locale,
                    segmentId: segmentId,
                    crossPlacementEligible: crossPlacementEligible,
                    disableServerCache: disableServerCache
                )
            }

        let configuration = session.configuration as? HTTPCodableConfiguration

        let response: HTTPResponse<AdaptyPlacementChosen> = try await perform(request) { @Sendable response in
            try await AdaptyPlacementChosen.decodePlacementVariationsResponse(
                response,
                withConfiguration: configuration,
                withProfileId: profileId,
                withPlacementId: placementId,
                withCached: cached,
                variationIdResolver: variationIdResolver
            )
        }

        return response.body
    }
}
