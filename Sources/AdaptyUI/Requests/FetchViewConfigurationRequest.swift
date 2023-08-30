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
    let queryItems: QueryItems

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

    init(paywallVariationId: String, locale: String, builderVersion: String, responseHash: String?) {
        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/paywall-builder/v2/\(paywallVariationId)/"
        )

        headers = Headers()
            .setBackendResponseHash(responseHash)

        queryItems = QueryItems()
            .setLocale(locale)
            .setBuilderVersion(builderVersion)
    }
}

extension HTTPSession {
    func performFetchViewConfigurationRequest(paywallId: String,
                                              paywallVariationId: String,
                                              locale: String,
                                              builderVersion: String,
                                              responseHash: String?,
                                              _ completion: @escaping AdaptyResultCompletion<VH<AdaptyUI.ViewConfiguration?>>) {
        let request = FetchViewConfigurationRequest(paywallVariationId: paywallVariationId,
                                                    locale: locale,
                                                    builderVersion: builderVersion,
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
                completion(.success(VH(paywall, hash: hash)))
            }
        }
    }
}
