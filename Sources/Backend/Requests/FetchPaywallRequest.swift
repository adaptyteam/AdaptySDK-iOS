//
//  FetchPaywallRequest.swift
//  Adapty
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

struct FetchPaywallRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.Body<AdaptyPaywall>

    let endpoint: HTTPEndpoint
    let headers: Headers

    init(apiKeyPrefix: String, profileId: String, paywallId: String, locale: AdaptyLocale, md5Hash: String) {
        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/paywall/\(paywallId)/\(md5Hash)/"
        )

        headers = Headers()
            .setPaywallLocale(locale)
            .setBackendProfileId(profileId)
    }
}

extension HTTPSession {
    func performFetchPaywallRequest(apiKeyPrefix: String,
                                    profileId: String,
                                    paywallId: String,
                                    locale: AdaptyLocale,
                                    segmentId: String,
                                    _ completion: @escaping AdaptyResultCompletion<VH<AdaptyPaywall>>) {
        let md5Hash = "{\"locale\":\"\(locale.id.lowercased())\",\"segment_hash\":\"\(segmentId)\",\"store\":\"app_store\"}".md5()

        let request = FetchPaywallRequest(apiKeyPrefix: apiKeyPrefix,
                                          profileId: profileId,
                                          paywallId: paywallId,
                                          locale: locale,
                                          md5Hash: md5Hash)

        perform(request, logName: "get_paywall",
                logParams: [
                    "api_prefix": .value(apiKeyPrefix),
                    "paywall_id": .value(paywallId),
                    "locale": .value(locale),
                    "segment_id": .value(segmentId),
                    "md5": .value(md5Hash),
                ]) { (result: FetchPaywallRequest.Result) in
            switch result {
            case let .failure(error):
                completion(.failure(error.asAdaptyError))
            case let .success(response):
                completion(.success(VH(response.body.value, time: Date())))
            }
        }
    }
}
