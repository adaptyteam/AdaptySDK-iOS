//
//  FetchViewConfigurationRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//

import Foundation

struct FetchViewConfigurationRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.ValueOfData<AdaptyUI.ViewConfiguration>

    let endpoint: HTTPEndpoint
    let headers: Headers

    init(apiKeyPrefix: String, paywallVariationId: String, locale: AdaptyLocale, md5Hash: String) {
        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/paywall-builder/\(paywallVariationId)/\(md5Hash)/"
        )

        headers = Headers()
            .setViewConfigurationLocale(locale)
            .setVisualBuilderVersion(AdaptyUI.builderVersion)
            .setAdaptyUISDKVersion(Adapty.SDKVersion)
    }
}

extension HTTPSession {
    func performFetchViewConfigurationRequest(
        apiKeyPrefix: String,
        paywallVariationId: String,
        locale: AdaptyLocale,
        _ completion: @escaping AdaptyResultCompletion<AdaptyUI.ViewConfiguration>
    ) {
        let md5Hash = "{\"builder_version\":\"\(AdaptyUI.builderVersion)\",\"locale\":\"\(locale.id.lowercased())\"}".md5.hexString

        let request = FetchViewConfigurationRequest(
            apiKeyPrefix: apiKeyPrefix,
            paywallVariationId: paywallVariationId,
            locale: locale,
            md5Hash: md5Hash
        )

        perform(
            request,
            logName: "get_paywall_builder",
            logParams: ["variation_id": .value(paywallVariationId)]
        ) { (result: FetchViewConfigurationRequest.Result) in
            switch result {
            case let .failure(error):
                completion(.failure(error.asAdaptyError))
            case let .success(response):
                completion(.success(response.body.value))
            }
        }
    }
}
