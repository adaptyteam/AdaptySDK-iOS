//
//  FetchPaywallVariationsRequest.swift
//
//
//  Created by Aleksei Valiano on 26.03.2024
//
//

import Foundation

private struct FetchPaywallVariationsRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = AdaptyPaywallChosen

    let endpoint: HTTPEndpoint
    let headers: Headers
    let profileId: String
    let cached: AdaptyPaywall?

    func getDecoder(_ jsonDecoder: JSONDecoder) -> (HTTPDataResponse) -> HTTPResponse<ResponseBody>.Result {
        createDecoder(jsonDecoder, profileId, cached)
    }

    init(apiKeyPrefix: String, profileId: String, placementId: String, locale: AdaptyLocale, md5Hash: String, segmentId: String, cached: AdaptyPaywall?) {
        self.profileId = profileId
        self.cached = cached

        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/paywall/variations/\(placementId)/\(md5Hash)/"
        )

        headers = Headers()
            .setPaywallLocale(locale)
            .setBackendProfileId(profileId)
            .setVisualBuilderVersion(AdaptyUI.builderVersion)
            .setVisualBuilderConfigurationFormatVersion(AdaptyUI.configurationFormatVersion)
            .setSegmentId(segmentId)
    }
}

extension HTTPRequestWithDecodableResponse where ResponseBody == AdaptyPaywallChosen {
    func createDecoder(
        _ jsonDecoder: JSONDecoder,
        _ profileId: String,
        _ cached: AdaptyPaywall?
    ) -> (HTTPDataResponse) -> HTTPResponse<ResponseBody>.Result {
        { response in
            decodeResponse(response, jsonDecoder, profileId, cached)
        }
    }

    func decodeResponse(
        _ response: HTTPDataResponse,
        _ jsonDecoder: JSONDecoder,
        _ profileId: String,
        _ cached: AdaptyPaywall?
    ) -> HTTPResponse<ResponseBody>.Result {
        jsonDecoder.setProfileId(profileId)

        typealias ResponseMeta = Backend.Response.ValueOfMeta<AdaptyPaywallChosen.Meta>
        typealias ResponseData = Backend.Response.ValueOfData<AdaptyPaywallChosen>

        let version: Int64

        switch jsonDecoder.decode(ResponseMeta.self, response) {
        case let .failure(error):
            return .failure(error)
        case let .success(value):
            version = value.body.meta.version
        }

        if let cached, cached.version > version {
            return .success(response.replaceBody(AdaptyPaywallChosen(
                value: cached,
                kind: .restore
            )))
        }

        return jsonDecoder.decode(ResponseData.self, response).map {
            var chosen = $0.body.value
            chosen.value.version = version
            return response.replaceBody(chosen)
        }
    }
}

extension HTTPSession {
    func performFetchPaywallVariationsRequest(
        apiKeyPrefix: String,
        profileId: String,
        placementId: String,
        locale: AdaptyLocale,
        segmentId: String,
        cached: AdaptyPaywall?,
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
            cached: cached
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
                "builder_config_format_version": .value(AdaptyUI.configurationFormatVersion),
                "md5": .value(md5Hash),
            ]
        ) { (result: FetchPaywallVariationsRequest.Result) in
            completion(result.map { $0.body }.mapError { $0.asAdaptyError })
        }
    }
}
