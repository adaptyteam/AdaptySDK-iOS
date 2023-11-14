//
//  FetchViewConfigurationRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.01.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

struct FetchViewConfigurationRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.ValueOfData<AdaptyUI.ViewConfiguration?>

    let endpoint: HTTPEndpoint
    let headers: Headers

    func getDecoder(_ jsonDecoder: JSONDecoder) -> ((HTTPDataResponse) -> HTTPResponse<ResponseBody>.Result) {
        { response in
            let result: Result<AdaptyUI.ViewConfiguration?, Error>

            if headers.hasSameBackendResponseHash(response.headers) {
                result = .success(nil)
            } else {
                result = jsonDecoder.decode(Backend.Response.ValueOfData<AdaptyUI.ViewConfiguration>.self, response.body).map { $0.value }
            }
            return result.map { response.replaceBody(Backend.Response.ValueOfData($0)) }
                .mapError { .decoding(response, error: $0) }
        }
    }

    init(apiKeyPrefix: String, paywallVariationId: String, locale: AdaptyLocale, md5Hash: String,  builderVersion: String, adaptyUISDKVersion: String, responseHash: String?) {
        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/paywall-builder/\(paywallVariationId)/\(md5Hash)/"
        )

        headers = Headers()
            .setViewConfigurationLocale(locale)
            .setVisualBuilderVersion(builderVersion)
            .setAdaptyUISDKVersion(adaptyUISDKVersion)
            .setBackendResponseHash(responseHash)
    }
}

extension HTTPSession {
    func performFetchViewConfigurationRequest(apiKeyPrefix: String,
                                              paywallVariationId: String,
                                              locale: AdaptyLocale,
                                              builderVersion: String,
                                              adaptyUISDKVersion: String,
                                              responseHash: String?,
                                              _ completion: @escaping AdaptyResultCompletion<VH<AdaptyUI.ViewConfiguration?>>) {
        let md5Hash = "{\"builder_version\":\"\(builderVersion)\",\"locale\":\"\(locale.id.lowercased())\"}".md5()

        let request = FetchViewConfigurationRequest(apiKeyPrefix: apiKeyPrefix,
                                                    paywallVariationId: paywallVariationId,
                                                    locale: locale,
                                                    md5Hash: md5Hash,
                                                    builderVersion: builderVersion,
                                                    adaptyUISDKVersion: adaptyUISDKVersion,
                                                    responseHash: responseHash)

        perform(request,
                logName: "get_paywall_builder",
                logParams: ["variation_id": .value(paywallVariationId)]) { (result: FetchViewConfigurationRequest.Result) in
            switch result {
            case let .failure(error):
                completion(.failure(error.asAdaptyError))
            case let .success(response):
                let paywall = response.body.value
                let hash = response.headers.getBackendResponseHash()
                completion(.success(VH(paywall, hash: hash, time: Date())))
            }
        }
    }
}
