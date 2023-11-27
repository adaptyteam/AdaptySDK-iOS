//
//  FetchFallbackPaywallRequest.swift
//  Adapty
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

struct FetchFallbackPaywallRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.Body<AdaptyPaywall>

    let endpoint: HTTPEndpoint

    init(apiKeyPrefix: String, paywallId: String, locale: AdaptyLocale) {
        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/paywall/\(paywallId)/app_store/\(locale.languageCode)/fallback.json"
        )
    }
}

extension HTTPSession {
    func performFetchFallbackPaywallRequest(
        apiKeyPrefix: String,
        paywallId: String,
        locale: AdaptyLocale?,
        _ completion: @escaping AdaptyResultCompletion<VH<AdaptyPaywall>>) {
        let locale = locale ?? AdaptyLocale.defaultPaywallLocale
        let request = FetchFallbackPaywallRequest(apiKeyPrefix: apiKeyPrefix,
                                                  paywallId: paywallId,
                                                  locale: locale)

        perform(request, logName: "get_fallback_paywall",
                logParams: [
                    "api_prefix": .value(apiKeyPrefix),
                    "paywall_id": .value(paywallId),
                    "language_code": .valueOrNil(locale.languageCode),
                ]) { [weak self] (result: FetchFallbackPaywallRequest.Result) in
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
                    session.performFetchFallbackPaywallRequest(apiKeyPrefix: apiKeyPrefix,
                                                               paywallId: paywallId,
                                                               locale: nil,
                                                               completion)
                }

            case let .success(response):
                let paywall = response.body.value
                completion(.success(VH(paywall, time: Date())))
            }
        }
    }
}
