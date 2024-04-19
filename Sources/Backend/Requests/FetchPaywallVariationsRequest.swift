//
//  FetchPaywallVariationsRequest.swift
//
//
//  Created by Aleksei Valiano on 26.03.2024
//
//

import Foundation

private struct FetchPaywallVariationsRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.ValueOfDataWithMeta<AdaptyPaywallChosen, AdaptyPaywallChosen.Meta>

    let endpoint: HTTPEndpoint
    let headers: Headers
    let profileId: String
    let version: Int64?

    func getDecoder(_ jsonDecoder: JSONDecoder) -> ((HTTPDataResponse) -> HTTPResponse<ResponseBody>.Result) {
        { response in
            jsonDecoder.setProfileId(profileId)
            return jsonDecoder.decode(ResponseBody.self, response)
        }
    }

    init(apiKeyPrefix: String, profileId: String, placementId: String, locale: AdaptyLocale, md5Hash: String, segmentId: String, version: Int64?) {
        self.profileId = profileId
        self.version = version

        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/paywall/variations/\(placementId)/\(md5Hash)/"
        )

        headers = Headers()
            .setPaywallLocale(locale)
            .setBackendProfileId(profileId)
            .setVisualBuilderVersion(AdaptyUI.builderVersion)
            .setSegmentId(segmentId)
    }
}

extension HTTPSession {
    func performFetchPaywallVariationsRequest(
        apiKeyPrefix: String,
        profileId: String,
        placementId: String,
        locale: AdaptyLocale,
        segmentId: String,
        version: Int64?,
        _ completion: @escaping AdaptyResultCompletion<AdaptyPaywallChosen>
    ) {
        let md5Hash = "{\"builder_version\":\"\(AdaptyUI.builderVersion)\",\"locale\":\"\(locale.id.lowercased())\",\"segment_hash\":\"\(segmentId)\",\"store\":\"app_store\"}".md5.hexString

        let request = FetchPaywallVariationsRequest(
            apiKeyPrefix: apiKeyPrefix,
            profileId: profileId,
            placementId: placementId,
            locale: locale,
            md5Hash: md5Hash,
            segmentId: segmentId,
            version: version
        )

        perform(
            request,
            logName: "get_paywall_variations",
            logParams: [
                "api_prefix": .value(apiKeyPrefix),
                "placement_id": .value(placementId),
                "locale": .value(locale),
                "segment_id": .value(segmentId),
                "builder_version": .value(AdaptyUI.builderVersion),
                "md5": .value(md5Hash),
            ]
        ) { (result: FetchPaywallVariationsRequest.Result) in
            switch result {
            case let .failure(error):
                completion(.failure(error.asAdaptyError))
            case let .success(response):
                var chosen = response.body.value
                chosen.value.version = response.body.meta.version
                completion(.success(chosen))
            }
        }
    }
}
