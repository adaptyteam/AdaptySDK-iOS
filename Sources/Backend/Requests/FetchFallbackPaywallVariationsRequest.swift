//
//  FetchFallbackPaywallRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.03.2024
//

import Foundation

private struct FetchFallbackPaywallVariationsRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.Body<AdaptyPaywall>

    let endpoint: HTTPEndpoint

    init(apiKeyPrefix: String, placementId: String, locale: AdaptyLocale, builderVersion: String) {
        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/paywall/variations/\(placementId)/app_store/\(locale.languageCode.lowercased())/\(builderVersion)/fallback.json"
        )
    }
}

extension HTTPSession {
    func performFetchFallbackPaywallVariationsRequest(
        apiKeyPrefix: String,
        placementId: String,
        locale: AdaptyLocale?,
        builderVersion: String,
        _ completion: @escaping AdaptyResultCompletion<VH<AdaptyPaywall>>
    ) {
        let locale = locale ?? AdaptyLocale.defaultPaywallLocale
        let request = FetchFallbackPaywallVariationsRequest(
            apiKeyPrefix: apiKeyPrefix,
            placementId: placementId,
            locale: locale,
            builderVersion: builderVersion
        )

        perform(
            request,
            logName: "get_fallback_paywall_variations",
            logParams: [
                "api_prefix": .value(apiKeyPrefix),
                "placement_id": .value(placementId),
                "language_code": .valueOrNil(locale.languageCode),
                "builder_version": .value(builderVersion),
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
                        placementId: placementId,
                        locale: nil,
                        builderVersion: builderVersion,
                        completion
                    )
                }

            case let .success(response):
                let paywall = response.body.value
                completion(.success(VH(paywall, time: Date())))
            }
        }
    }
}
