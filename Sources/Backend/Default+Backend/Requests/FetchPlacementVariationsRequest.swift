//
//  FetchPlacementVariationsRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.03.2024
//

import Foundation

private struct FetchPaywallVariationsRequest: BackendRequest {
    let endpoint: HTTPEndpoint
    let headers: HTTPHeaders
    let queryItems: QueryItems
    let stamp = Log.stamp

    let logName = APIRequestName.fetchPaywallVariations
    let logParams: EventParameters?

    init(
        apiKeyPrefix: String,
        userId: AdaptyUserId,
        placementId: String,
        locale: AdaptyLocale,
        segmentId: String,
        crossPlacementEligible: Bool,
        disableServerCache: Bool
    ) {
        let md5Hash = "{\"builder_version\":\"\(Adapty.uiBuilderVersion)\",\(crossPlacementEligible ? "\"cross_placement_eligibility\":true," : "")\"locale\":\"\(locale.id.lowercased())\",\"segment_hash\":\"\(segmentId)\",\"store\":\"app_store\"}".md5.hexString

        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/paywall/variations/\(placementId)/\(md5Hash)/"
        )

        headers = HTTPHeaders()
            .setPaywallLocale(locale)
            .setUserProfileId(userId)
            .setPaywallBuilderVersion(Adapty.uiBuilderVersion)
            .setPaywallBuilderConfigurationFormatVersion(Adapty.uiSchemaVersion)
            .setCrossPlacementEligibility(crossPlacementEligible)
            .setSegmentId(segmentId)

        queryItems = QueryItems().setDisableServerCache(disableServerCache)

        logParams = [
            "api_prefix": apiKeyPrefix,
            "placement_id": placementId,
            "locale": locale,
            "segment_id": segmentId,
            "builder_version": Adapty.uiBuilderVersion,
            "builder_config_format_version": Adapty.uiSchemaVersion,
            "md5": md5Hash,
            "cross_placement_eligibility": crossPlacementEligible,
            "disable_server_cache": disableServerCache,
        ]
    }
}

private struct FetchOnboardingVariationsRequest: BackendRequest {
    let endpoint: HTTPEndpoint
    let headers: HTTPHeaders
    let queryItems: QueryItems
    let stamp = Log.stamp

    let logName = APIRequestName.fetchOnboardingVariations
    let logParams: EventParameters?

    init(
        apiKeyPrefix: String,
        userId: AdaptyUserId,
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
            .setUserProfileId(userId)
            .setOnboardingUIVersion(AdaptyOnboarding.ViewConfiguration.uiVersion)
            .setCrossPlacementEligibility(crossPlacementEligible)
            .setSegmentId(segmentId)

        queryItems = QueryItems()
            .setDisableServerCache(disableServerCache)

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

extension Backend.DefaultExecutor {
    func fetchPlacementVariations<Content: PlacementContent>(
        apiKeyPrefix: String,
        userId: AdaptyUserId,
        placementId: String,
        locale: AdaptyLocale,
        segmentId: String,
        cached: Content?,
        crossPlacementEligible: Bool,
        variationIdResolver: AdaptyPlacementChosen<Content>.VariationIdResolver?,
        disableServerCache: Bool
    ) async throws(HTTPError) -> AdaptyPlacementChosen<Content> {
        let request: BackendRequest =
            if Content.self == AdaptyPaywall.self {
                FetchPaywallVariationsRequest(
                    apiKeyPrefix: apiKeyPrefix,
                    userId: userId,
                    placementId: placementId,
                    locale: locale,
                    segmentId: segmentId,
                    crossPlacementEligible: crossPlacementEligible,
                    disableServerCache: disableServerCache
                )

            } else {
                FetchOnboardingVariationsRequest(
                    apiKeyPrefix: apiKeyPrefix,
                    userId: userId,
                    placementId: placementId,
                    locale: locale,
                    segmentId: segmentId,
                    crossPlacementEligible: crossPlacementEligible,
                    disableServerCache: disableServerCache
                )
            }

        let response = try await perform(request, withDecoder: AdaptyPlacementChosen.createDecoder(
            withUserId: userId,
            withPlacementId: placementId,
            withRequestLocale: locale,
            withCached: cached,
            variationIdResolver: variationIdResolver
        ))

        return response.body
    }
}
