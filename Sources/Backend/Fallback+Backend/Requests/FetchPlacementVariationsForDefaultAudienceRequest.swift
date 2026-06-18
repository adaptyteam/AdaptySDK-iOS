//
//  FetchPlacementVariationsForDefaultAudienceRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.03.2024
//

import Foundation

private struct FetchPlacementVariationsForDefaultAudienceRequest: BackendRequest {
    let endpoint: HTTPEndpoint
    let stamp = Log.stamp
    let queryItems: QueryItems
    let timeoutInterval: TimeInterval?
    let requestName: BackendRequestName
    let logParams: EventParameters?

    init<Content: PlacementContent>(
        _ type: Content.Type,
        apiKeyPrefix: String,
        placementId: String,
        locale: AdaptyLocale,
        disableServerCache: Bool,
        timeoutInterval: TimeInterval?
    ) throws(HTTPError) {
        if type == AdaptyFlow.self {
            endpoint = HTTPEndpoint(
                method: .get,
                path: "/sdk/in-apps/\(apiKeyPrefix)/flow/variations/\(placementId)/app_store/fallback.json"
            )
            requestName = .fetchFlowVariationsForDefaultAudience
            logParams = [
                "api_prefix": apiKeyPrefix,
                "placement_id": placementId,
                "builder_version": Adapty.uiBuilderVersion,
                "builder_config_format_version": Adapty.uiSchemaVersion,
                "disable_server_cache": disableServerCache,
            ]

        } else if type == AdaptyOnboarding.self {
            endpoint = HTTPEndpoint(
                method: .get,
                path:
                "/sdk/in-apps/\(apiKeyPrefix)/onboarding/variations/\(placementId)/\(locale.languageCode.lowercased())/fallback.json"
            )
            requestName = .fetchOnboardingVariationsForDefaultAudience
            logParams = [
                "api_prefix": apiKeyPrefix,
                "placement_id": placementId,
                "language_code": locale.languageCode,
                "builder_version": Adapty.uiBuilderVersion,
                "builder_config_format_version": Adapty.uiSchemaVersion,
                "disable_server_cache": disableServerCache,
            ]

        } else {
            throw .notAvailable("Not available for \(String(describing: Content.self))")
        }

        self.timeoutInterval =
            if let timeoutInterval {
                min(max(0.5, timeoutInterval), 60)
            } else {
                nil
            }

        queryItems = QueryItems().setDisableServerCache(disableServerCache)
    }
}

extension Backend.DefaultAudienceExecutor {
    func fetchPlacementVariationsForDefaultAudience<Content: PlacementContent>(
        _ type: Content.Type,
        apiKeyPrefix: String,
        userId: AdaptyUserId,
        placementId: String,
        locale: AdaptyLocale? = nil,
        disableServerCache: Bool,
        timeoutInterval: TimeInterval?
    ) async throws(HTTPError) -> AdaptyPlacement.Draw<Content> {
        try await _fetchPlacementVariationsForDefaultAudience(
            type,
            apiKeyPrefix,
            placementId,
            locale ?? .defaultPlacementLocale,
            disableServerCache,
            timeoutInterval,
            withDecoder: AdaptyPlacement.Draw<Content>.placementVariationsDecoder(
                withUserId: userId,
                withPlacementId: placementId,
                withRequestLocale: locale,
                crossPlacementEligible: false
            )
        )
    }

    func preloadPlacementVariationsForDefaultAudience<Content: PlacementContent>(
        _ type: Content.Type,
        apiKeyPrefix: String,
        userId: AdaptyUserId,
        placementId: String,
        locale: AdaptyLocale? = nil,
        disableServerCache: Bool,
        timeoutInterval: TimeInterval?
    ) async throws(HTTPError) {
        _ = try await _fetchPlacementVariationsForDefaultAudience(
            type,
            apiKeyPrefix,
            placementId,
            locale ?? .defaultPlacementLocale,
            disableServerCache,
            timeoutInterval,
            withDecoder: AdaptyPlacement.Draw<Content>.persistPlacementVariations(
                withUserId: userId,
                withPlacementId: placementId,
                withRequestLocale: locale,
                crossPlacementEligible: false
            )
        )
    }

    private func _fetchPlacementVariationsForDefaultAudience<Content: PlacementContent, ResponseBody: Sendable>(
        _ type: Content.Type,
        _ apiKeyPrefix: String,
        _ placementId: String,
        _ requestLocale: AdaptyLocale,
        _ disableServerCache: Bool,
        _ timeoutInterval: TimeInterval?,
        withDecoder decoder: @escaping HTTPDecoder<ResponseBody>
    ) async throws(HTTPError) -> ResponseBody {
        var locale = requestLocale
        var timeoutInterval = timeoutInterval
        var lastError: HTTPError
        repeat {
            let request = try FetchPlacementVariationsForDefaultAudienceRequest(
                type,
                apiKeyPrefix: apiKeyPrefix,
                placementId: placementId,
                locale: locale,
                disableServerCache: disableServerCache,
                timeoutInterval: timeoutInterval
            )

            let startRequestTime = Date()

            do throws(HTTPError) {
                let response = try await perform(request, withDecoder: decoder)
                return response.body
            } catch {
                if error.statusCode == 404,
                   Content.self == AdaptyOnboarding.self,
                   !locale.equalLanguageCode(AdaptyLocale.defaultPlacementLocale)
                {
                    locale = .defaultPlacementLocale
                    timeoutInterval = timeoutInterval?.added(startRequestTime.timeIntervalSinceNow)
                    lastError = error
                    continue
                } else {
                    throw error
                }
            }
        } while !Task.isCancelled

        throw lastError
    }
}

