//
//  FetchFallbackPlacementVariationsRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.03.2024
//

import Foundation

private struct FetchFallbackPlacementVariationsRequest: BackendRequest {
    let endpoint: HTTPEndpoint
    let stamp = Log.stamp
    let queryItems: QueryItems
    let timeoutInterval: TimeInterval?
    let requestName: BackendRequestName
    let logParams: EventParameters?

    init(
        endpoint: HTTPEndpoint,
        disableServerCache: Bool,
        timeoutInterval: TimeInterval?,
        logName: BackendRequestName,
        logParams: EventParameters
    ) {
        self.timeoutInterval =
            if let timeoutInterval {
                min(max(0.5, timeoutInterval), 60)
            } else {
                nil
            }

        self.endpoint = endpoint
        queryItems = QueryItems().setDisableServerCache(disableServerCache)

        requestName = logName
        self.logParams = logParams
    }
}

extension Backend.FallbackExecutor {
    func fetchFallbackPlacementVariations<Content: PlacementContent>(
        apiKeyPrefix: String,
        userId: AdaptyUserId,
        placementId: String,
        locale: AdaptyLocale? = nil,
        disableServerCache: Bool,
        timeoutInterval: TimeInterval?
    ) async throws(HTTPError) -> AdaptyPlacementChosen<Content> {
        try await _fetchFallbackPlacementVariations(
            apiKeyPrefix,
            userId,
            placementId,
            locale ?? .defaultPlacementLocale,
            disableServerCache,
            timeoutInterval
        )
    }
}

extension Backend.ConfigsExecutor {
    func fetchPlacementVariationsForDefaultAudience<Content: PlacementContent>(
        apiKeyPrefix: String,
        userId: AdaptyUserId,
        placementId: String,
        locale: AdaptyLocale? = nil,
        disableServerCache: Bool,
        timeoutInterval: TimeInterval?
    ) async throws(HTTPError) -> AdaptyPlacementChosen<Content> {
        try await _fetchFallbackPlacementVariations(
            apiKeyPrefix,
            userId,
            placementId,
            locale ?? .defaultPlacementLocale,
            disableServerCache,
            timeoutInterval
        )
    }
}

private extension BackendExecutor {
    func _fetchFallbackPlacementVariations<Content: PlacementContent>(
        _ apiKeyPrefix: String,
        _ userId: AdaptyUserId,
        _ placementId: String,
        _ requestLocale: AdaptyLocale,
        _ disableServerCache: Bool,
        _ timeoutInterval: TimeInterval?
    ) async throws(HTTPError) -> AdaptyPlacementChosen<Content> {
        var locale = requestLocale
        var timeoutInterval = timeoutInterval
        var lastError: HTTPError
        repeat {
            let endpoint: HTTPEndpoint
            let requestName: BackendRequestName
            let logParams: EventParameters
            if Content.self == AdaptyFlow.self {
                endpoint = HTTPEndpoint(
                    method: .get,
                    path: "/sdk/in-apps/\(apiKeyPrefix)/flow/variations/\(placementId)/app_store/fallback.json"
                )
                requestName = kind == .fallback ? .fetchFallbackPaywallVariations : .fetchPaywallVariationsForDefaultAudience

                logParams = [
                    "api_prefix": apiKeyPrefix,
                    "placement_id": placementId,
                    "builder_version": Adapty.uiBuilderVersion,
                    "builder_config_format_version": Adapty.uiSchemaVersion,
                    "disable_server_cache": disableServerCache,
                ]

            } else if Content.self == AdaptyOnboarding.self {
                endpoint = HTTPEndpoint(
                    method: .get,
                    path:
                    "/sdk/in-apps/\(apiKeyPrefix)/onboarding/variations/\(placementId)/\(locale.languageCode.lowercased())/fallback.json"
                )
                requestName = kind == .fallback ? .fetchFallbackOnboardingVariations : .fetchOnboardingVariationsForDefaultAudience

                logParams = [
                    "api_prefix": apiKeyPrefix,
                    "placement_id": placementId,
                    "language_code": locale.languageCode,
                    "request_locale": requestLocale.id,
                    "builder_version": Adapty.uiBuilderVersion,
                    "builder_config_format_version": Adapty.uiSchemaVersion,
                    "disable_server_cache": disableServerCache,
                ]

            } else {
                throw .notAvailable("Not available for \(String(describing: Content.self))")
            }

            let request = FetchFallbackPlacementVariationsRequest(
                endpoint: endpoint,
                disableServerCache: disableServerCache,
                timeoutInterval: timeoutInterval,
                logName: requestName,
                logParams: logParams
            )

            let startRequestTime = Date()

            do throws(HTTPError) {
                let response = try await perform(request, withDecoder: AdaptyPlacement.Draw<Content>.placementVariationsDecoder(
                    withUserId: userId,
                    withPlacementId: placementId,
                    withRequestLocale: requestLocale,
                    crossPlacementEligible: false
                ))

                return .draw(response.body)
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
