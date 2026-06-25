//
//  FetchFallbackPlacementRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.01.2025.
//

import Foundation

private struct FetchPlacementForDefaultAudienceRequest: BackendRequest {
    let endpoint: HTTPEndpoint
    let queryItems: QueryItems
    let stamp = Log.stamp
    let timeoutInterval: TimeInterval?
    let requestName: BackendRequestName
    let logParams: EventParameters?

    init<Content: PlacementContent>(
        _ type: Content.Type,
        apiKeyPrefix: String,
        placementId: String,
        variationId: String,
        locale: AdaptyLocale,
        disableServerCache: Bool,
        timeoutInterval: TimeInterval?
    ) throws(HTTPError) {
        if type == AdaptyFlow.self {
            endpoint = HTTPEndpoint(
                method: .get,
                path:
                "/sdk/in-apps/\(apiKeyPrefix)/flow/variations/\(placementId)/\(variationId)/app_store/\(Adapty.uiBuilderVersion)/fallback.json"
            )
            requestName = .fetchFlowForDefaultAudience
            logParams = [
                "api_prefix": apiKeyPrefix,
                "placement_id": placementId,
                "variation_id": variationId,
                "builder_version": Adapty.uiBuilderVersion,
                "builder_config_format_version": Adapty.uiSchemaVersion,
                "disable_server_cache": disableServerCache,
            ]

        } else if type == AdaptyOnboarding.self {
            endpoint = HTTPEndpoint(
                method: .get,
                path: "/sdk/in-apps/\(apiKeyPrefix)/onboarding/variations/\(placementId)/\(variationId)/\(locale.languageCode)/fallback.json"
            )
            requestName = .fetchOnbordingForDefaultAudience
            logParams = [
                "api_prefix": apiKeyPrefix,
                "placement_id": placementId,
                "variation_id": variationId,
                "language_code": locale.languageCode,
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
    func fetchPlacementForDefaultAudience<Content: PlacementContent>(
        _ type: Content.Type,
        apiKeyPrefix: String,
        userId: AdaptyUserId,
        placementId: String,
        variationId: String,
        locale: AdaptyLocale? = nil,
        disableServerCache: Bool,
        timeoutInterval: TimeInterval?
    ) async throws(HTTPError) -> AdaptyPlacement.Draw<Content> {
        let locale = locale ?? .defaultPlacementLocale
        return try await _fetchPlacementForDefaultAudience(
            type,
            apiKeyPrefix,
            placementId,
            variationId,
            locale,
            disableServerCache,
            timeoutInterval,
            withDecoder: AdaptyPlacement.Draw<Content>.placementDecoder(
                withUserId: userId,
                withVariationId: variationId,
                withRequestLocale: locale
            )
        )
    }

    func preloadPlacementForDefaultAudience<Content: PlacementContent>(
        _ type: Content.Type,
        apiKeyPrefix: String,
        placementId: String,
        variationId: String,
        locale: AdaptyLocale? = nil,
        disableServerCache: Bool,
        timeoutInterval: TimeInterval?
    ) async throws(HTTPError) {
        let locale = locale ?? .defaultPlacementLocale
        _ = try await _fetchPlacementForDefaultAudience(
            type,
            apiKeyPrefix,
            placementId,
            variationId,
            locale,
            disableServerCache,
            timeoutInterval,
            withDecoder: AdaptyPlacement.Draw<Content>.persistPlacement(
                withVariationId: variationId,
                withRequestLocale: locale
            )
        )
    }

    private func _fetchPlacementForDefaultAudience<Content: PlacementContent, ResponseBody: Sendable>(
        _ type: Content.Type,
        _ apiKeyPrefix: String,
        _ placementId: String,
        _ variationId: String,
        _ requestLocale: AdaptyLocale,
        _ disableServerCache: Bool,
        _ timeoutInterval: TimeInterval?,
        withDecoder decoder: @escaping HTTPDecoder<ResponseBody>
    ) async throws(HTTPError) -> ResponseBody {
        var locale = requestLocale
        var timeoutInterval = timeoutInterval
        var lastError: HTTPError
        repeat {
            let request = try FetchPlacementForDefaultAudienceRequest(
                type,
                apiKeyPrefix: apiKeyPrefix,
                placementId: placementId,
                variationId: variationId,
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
