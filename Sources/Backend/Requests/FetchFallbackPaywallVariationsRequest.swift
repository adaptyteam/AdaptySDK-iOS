//
//  FetchFallbackPaywallRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.03.2024
//

import Foundation

private struct FetchFallbackPaywallVariationsRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = AdaptyPaywallChosen

    let endpoint: HTTPEndpoint
    let profileId: String
    let cached: AdaptyPaywall?
    let queryItems: QueryItems

    func getDecoder(_ jsonDecoder: JSONDecoder) -> (HTTPDataResponse) -> HTTPResponse<ResponseBody>.Result {
        createDecoder(jsonDecoder, profileId, cached)
    }

    init(apiKeyPrefix: String, profileId: String, placementId: String, locale: AdaptyLocale, cached: AdaptyPaywall?, disableServerCache: Bool) {
        self.profileId = profileId
        self.cached = cached
        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/paywall/variations/\(placementId)/app_store/\(locale.languageCode.lowercased())/\(AdaptyUI.builderVersion)/fallback.json"
        )
        queryItems = QueryItems().setDisableServerCache(disableServerCache)
    }
}

extension HTTPSession {
    func performFetchFallbackPaywallVariationsRequest(
        apiKeyPrefix: String,
        profileId: String,
        placementId: String,
        locale: AdaptyLocale,
        cached: AdaptyPaywall?,
        disableServerCache: Bool,
        _ completion: @escaping AdaptyResultCompletion<AdaptyPaywallChosen>
    ) {
        let request = FetchFallbackPaywallVariationsRequest(
            apiKeyPrefix: apiKeyPrefix,
            profileId: profileId,
            placementId: placementId,
            locale: locale,
            cached: cached,
            disableServerCache: disableServerCache
        )

        perform(
            request,
            logName: "get_fallback_paywall_variations",
            logParams: [
                "api_prefix": .value(apiKeyPrefix),
                "placement_id": .value(placementId),
                "language_code": .valueOrNil(locale.languageCode),
                "builder_version": .value(AdaptyUI.builderVersion),
                "builder_config_format_version": .value(AdaptyUI.configurationFormatVersion),
                "disable_server_cache": .value(disableServerCache),
            ]
        ) { [weak self] (result: FetchFallbackPaywallVariationsRequest.Result) in
            switch result {
            case let .failure(error):
                guard let queue = self?.responseQueue,
                      error.statusCode == 404,
                      !locale.equalLanguageCode(AdaptyLocale.defaultPaywallLocale) else {
                    completion(.failure(error.asAdaptyError))
                    break
                }

                queue.async {
                    guard let session = self else {
                        completion(.failure(error.asAdaptyError))
                        return
                    }
                    session.performFetchFallbackPaywallVariationsRequest(
                        apiKeyPrefix: apiKeyPrefix,
                        profileId: profileId,
                        placementId: placementId,
                        locale: .defaultPaywallLocale,
                        cached: cached,
                        disableServerCache: disableServerCache,
                        completion
                    )
                }

            case let .success(response):
                completion(.success(response.body))
            }
        }
    }
}
