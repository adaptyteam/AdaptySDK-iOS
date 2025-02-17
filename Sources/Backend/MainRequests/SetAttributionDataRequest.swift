//
//  SetAttributionDataRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

private struct SetAttributionDataRequest: HTTPEncodableRequest, HTTPRequestWithDecodableResponse {
    typealias ResponseBody = AdaptyProfile?
    let endpoint = HTTPEndpoint(
        method: .post,
        path: "/sdk/attribution/profile/set/data/"
    )
    let headers: HTTPHeaders
    let contentType: String? = "application/json"
    let stamp = Log.stamp

    let source: String
    let attributionJson: String
    let profileId: String

    func decodeDataResponse(
        _ response: HTTPDataResponse,
        withConfiguration configuration: HTTPCodableConfiguration?
    ) throws -> Response {
        try Self.decodeResponse(
            response,
            withConfiguration: configuration,
            requestHeaders: headers
        )
    }

    init(profileId: String, source: String, attributionJson: String, responseHash: String?) {
        headers = HTTPHeaders()
            .setBackendProfileId(profileId)
            .setBackendResponseHash(responseHash)

        self.source = source
        self.attributionJson = attributionJson
        self.profileId = profileId
    }

    enum CodingKeys: String, CodingKey {
        case source
        case attributionJson = "attribution_json"
        case profileId = "profile_id"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(source, forKey: .source)
        try container.encode(attributionJson, forKey: .attributionJson)
        try container.encode(profileId, forKey: .profileId)
    }
}

extension Backend.MainExecutor {
    func setAttributionData(
        profileId: String,
        source: String,
        attributionJson: String,
        responseHash: String?
    ) async throws -> VH<AdaptyProfile?> {
        let request = SetAttributionDataRequest(
            profileId: profileId,
            source: source,
            attributionJson: attributionJson,
            responseHash: responseHash
        )
        let response = try await perform(
            request,
            requestName: .setAttributionData,
            logParams: [
                "source": source,
            ]
        )

        return VH(response.body, hash: response.headers.getBackendResponseHash())
    }
}
