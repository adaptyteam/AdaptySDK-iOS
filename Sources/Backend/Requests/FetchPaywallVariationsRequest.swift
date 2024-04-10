//
//  FetchPaywallVariationsRequest.swift
//
//
//  Created by Aleksei Valiano on 26.03.2024
//
//

import Foundation

private struct FetchPaywallVariationsRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.Body<AdaptyPaywall>

    let endpoint: HTTPEndpoint
    let headers: Headers

    init(apiKeyPrefix: String, profileId: String, placementId: String, locale: AdaptyLocale, md5Hash: String, segmentId: String, builderVersion: String, adaptyUISDKVersion: String?) {
        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/\(apiKeyPrefix)/paywall/variations/\(placementId)/\(md5Hash)/"
        )

        headers = Headers()
            .setPaywallLocale(locale)
            .setBackendProfileId(profileId)
            .setVisualBuilderVersion(builderVersion)
            .setAdaptyUISDKVersion(adaptyUISDKVersion)
            .setSegmentId(segmentId)
    }
}

extension HTTPSession {
    func performFetchPaywallVariationsRequest(
        apiKeyPrefix: String,
        profileId: String,
        placementId: String,
        locale: AdaptyLocale?,
        segmentId: String,
        builderVersion: String,
        adaptyUISDKVersion: String?,
        _ completion: @escaping AdaptyResultCompletion<VH<AdaptyPaywall>>
    ) {
        let locale = locale ?? AdaptyLocale.defaultPaywallLocale

        let md5Hash = "{\"builder_version\":\"\(builderVersion)\",\"locale\":\"\(locale.id.lowercased())\",\"segment_hash\":\"\(segmentId)\",\"store\":\"app_store\"}".md5.hexString

        let request = FetchPaywallVariationsRequest(
            apiKeyPrefix: apiKeyPrefix,
            profileId: profileId,
            placementId: placementId,
            locale: locale,
            md5Hash: md5Hash,
            segmentId: segmentId,
            builderVersion: builderVersion,
            adaptyUISDKVersion: adaptyUISDKVersion
        )

        perform(
            request,
            logName: "get_paywall_variations",
            logParams: [
                "api_prefix": .value(apiKeyPrefix),
                "placement_id": .value(placementId),
                "locale": .value(locale),
                "segment_id": .value(segmentId),
                "builder_version": .value(builderVersion),
                "md5": .value(md5Hash),
            ]
        ) { (result: FetchPaywallVariationsRequest.Result) in
            switch result {
            case let .failure(error):
                completion(.failure(error.asAdaptyError))
            case let .success(response):
                completion(.success(VH(response.body.value, time: Date())))
            }
        }
    }
}
