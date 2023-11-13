//
//  FetchPaywallRequest.swift
//  Adapty
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

struct FetchPaywallRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.Body<AdaptyPaywall?>

    let endpoint: HTTPEndpoint
    let headers: Headers

    func getDecoder(_ jsonDecoder: JSONDecoder) -> ((HTTPDataResponse) -> HTTPResponse<ResponseBody>.Result) {
        { response in
            let result: Result<AdaptyPaywall?, Error>

            if headers.hasSameBackendResponseHash(response.headers) {
                result = .success(nil)
            } else {
                result = jsonDecoder.decode(Backend.Response.Body<AdaptyPaywall>.self, response.body).map { $0.value }
            }
            return result.map { response.replaceBody(Backend.Response.Body($0)) }
                .mapError { .decoding(response, error: $0) }
        }
    }

    init(apiKeyPrefix: String, paywallId: String, locale: AdaptyLocale, md5Hash: String, responseHash: String?) {
        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/paywall/\(paywallId)/\(md5Hash)/"
        )

        headers = Headers()
            .setPaywallLocale(locale)
            .setBackendResponseHash(responseHash)
    }
}

extension HTTPSession {
    func performFetchPaywallRequest(apiKeyPrefix: String,
                                    paywallId: String,
                                    locale: AdaptyLocale,
                                    segmentId: String,
                                    responseHash: String?,
                                    _ completion: @escaping AdaptyResultCompletion<VH<AdaptyPaywall?>>) {
        let md5Hash = "{\"locale\":\"\(locale.id.lowercased())\",\"segment_hash\":\"\(segmentId)\",\"store\":\"app_store\"}".md5()

        let request = FetchPaywallRequest(apiKeyPrefix: apiKeyPrefix,
                                          paywallId: paywallId,
                                          locale: locale,
                                          md5Hash: md5Hash,
                                          responseHash: responseHash)

        perform(request, logName: "get_paywall",
                logParams: [
                    "api_prefix": .value(apiKeyPrefix),
                    "paywall_id": .value(paywallId),
                    "locale": .value(locale),
                    "segment_id": .value(segmentId),
                    "md5": .value(md5Hash)
                ]) { (result: FetchPaywallRequest.Result) in
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
