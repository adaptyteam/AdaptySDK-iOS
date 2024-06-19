//
//  FetchFallbackViewConfigurationRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

struct FetchFallbackViewConfigurationRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.ValueOfData<AdaptyUI.ViewConfiguration>

    let endpoint: HTTPEndpoint

    init(apiKeyPrefix: String, paywallInstanceIdentity: String, locale: AdaptyLocale) {
        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/paywall-builder/\(paywallInstanceIdentity)/\(AdaptyUI.builderVersion)/\(locale.languageCode)/fallback.json"
        )
    }
}

extension HTTPSession {
    func performFetchFallbackViewConfigurationRequest(
        apiKeyPrefix: String,
        paywallInstanceIdentity: String,
        locale: AdaptyLocale,
        _ completion: @escaping AdaptyResultCompletion<AdaptyUI.ViewConfiguration>
    ) {
        let request = FetchFallbackViewConfigurationRequest(
            apiKeyPrefix: apiKeyPrefix,
            paywallInstanceIdentity: paywallInstanceIdentity,
            locale: locale
        )
        perform(
            request,
            logName: "get_fallback_paywall_builder",
            logParams: [
                "api_prefix": .value(apiKeyPrefix),
                "paywall_instance_id": .value(paywallInstanceIdentity),
                "builder_version": .value(AdaptyUI.builderVersion),
                "builder_config_format_version": .value(AdaptyUI.configurationFormatVersion),
                "language_code": .valueOrNil(locale.languageCode),
            ]
        ) { [weak self] (result: FetchFallbackViewConfigurationRequest.Result) in
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
                    session.performFetchFallbackViewConfigurationRequest(
                        apiKeyPrefix: apiKeyPrefix,
                        paywallInstanceIdentity: paywallInstanceIdentity,
                        locale: .defaultPaywallLocale,
                        completion
                    )
                }

            case let .success(response):
                completion(.success(response.body.value))
            }
        }
    }
}
