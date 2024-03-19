//
//  FetchPaywallRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

private struct FetchPaywallRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.Body<AdaptyPaywall>

    let endpoint: HTTPEndpoint
    let headers: Headers
    let locale: AdaptyLocale

    static let localeCodeUserInfoKey = CodingUserInfoKey(rawValue: "request_paywall_locale")!

    func getDecoder(_ jsonDecoder: JSONDecoder) -> ((HTTPDataResponse) -> HTTPResponse<ResponseBody>.Result) {
        { response in
            jsonDecoder.userInfo[FetchPaywallRequest.localeCodeUserInfoKey] = locale
            return jsonDecoder.decode(ResponseBody.self, response)
        }
    }

    init(apiKeyPrefix: String, profileId: String, placementId: String, locale: AdaptyLocale, md5Hash: String) {
        self.locale = locale

        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/paywall/\(placementId)/\(md5Hash)/"
        )

        headers = Headers()
            .setPaywallLocale(locale)
            .setBackendProfileId(profileId)
    }
}

extension HTTPSession {
    func performFetchPaywallRequest(
        apiKeyPrefix: String,
        profileId: String,
        placementId: String,
        locale: AdaptyLocale?,
        segmentId: String,
        _ completion: @escaping AdaptyResultCompletion<VH<AdaptyPaywall>>
    ) {
        let locale = locale ?? AdaptyLocale.defaultPaywallLocale

        let md5Hash = "{\"locale\":\"\(locale.id.lowercased())\",\"segment_hash\":\"\(segmentId)\",\"store\":\"app_store\"}".md5()

        let request = FetchPaywallRequest(
            apiKeyPrefix: apiKeyPrefix,
            profileId: profileId,
            placementId: placementId,
            locale: locale,
            md5Hash: md5Hash
        )

        perform(
            request,
            logName: "get_paywall",
            logParams: [
                "api_prefix": .value(apiKeyPrefix),
                "placement_id": .value(placementId),
                "locale": .value(locale),
                "segment_id": .value(segmentId),
                "md5": .value(md5Hash),
            ]
        ) { (result: FetchPaywallRequest.Result) in
            switch result {
            case let .failure(error):
                completion(.failure(error.asAdaptyError))
            case let .success(response):
                completion(.success(VH(response.body.value, time: Date())))
            }
        }
    }
}
