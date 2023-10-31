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

    init(apiKeyPrefix: String, paywallId: String, localeCode: String, responseHash: String?) {
        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/paywall/\(paywallId)/app_store/\(localeCode)/fallback.json"
        )
    }
}

extension HTTPSession {
    func performFetchFallbackPaywallRequest(
        apiKeyPrefix: String,
        paywallId: String,
        localeCode: String,
        responseHash: String?,
        _ completion: @escaping AdaptyResultCompletion<VH<AdaptyPaywall>>) {
        let request = FetchFallbackPaywallRequest(apiKeyPrefix: apiKeyPrefix,
                                                  paywallId: paywallId,
                                                  localeCode: localeCode,
                                                  responseHash: responseHash)

        perform(request, logName: "get_fallback_paywall",
                logParams: [
                    "api_prefix": .value(apiKeyPrefix),
                    "paywall_id": .value(paywallId),
                    "locale_code": .valueOrNil(localeCode),
                ]) { (result: FetchFallbackPaywallRequest.Result) in
            switch result {
            case let .failure(error):
                completion(.failure(error.asAdaptyError))
            case let .success(response):
                let paywall = response.body.value
                let hash = response.headers.getBackendResponseHash()
                completion(.success(VH(paywall, hash: hash)))
            }
        }
    }
}
