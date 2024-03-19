//
//  FetchFallbackPaywallRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

private struct FetchFallbackPaywallRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.Body<AdaptyPaywall>

    let endpoint: HTTPEndpoint
    let locale: AdaptyLocale

    func getDecoder(_ jsonDecoder: JSONDecoder) -> ((HTTPDataResponse) -> HTTPResponse<ResponseBody>.Result) {
        { response in
            jsonDecoder.userInfo[Backend.Request.localeCodeUserInfoKey] = locale
            return jsonDecoder.decode(ResponseBody.self, response)
        }
    }

    init(apiKeyPrefix: String, placementId: String, locale: AdaptyLocale) {
        self.locale = locale
        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/paywall/\(placementId)/app_store/\(locale.languageCode.lowercased())/fallback.json"
        )
    }
}

extension HTTPSession {
    func performFetchFallbackPaywallRequest(
        apiKeyPrefix: String,
        placementId: String,
        locale: AdaptyLocale?,
        _ completion: @escaping AdaptyResultCompletion<VH<AdaptyPaywall>>
    ) {
        let locale = locale ?? AdaptyLocale.defaultPaywallLocale
        let request = FetchFallbackPaywallRequest(
            apiKeyPrefix: apiKeyPrefix,
            placementId: placementId,
            locale: locale
        )

        perform(
            request,
            logName: "get_fallback_paywall",
            logParams: [
                "api_prefix": .value(apiKeyPrefix),
                "placement_id": .value(placementId),
                "language_code": .valueOrNil(locale.languageCode),
            ]
        ) { [weak self] (result: FetchFallbackPaywallRequest.Result) in
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
                    session.performFetchFallbackPaywallRequest(
                        apiKeyPrefix: apiKeyPrefix,
                        placementId: placementId,
                        locale: nil,
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
