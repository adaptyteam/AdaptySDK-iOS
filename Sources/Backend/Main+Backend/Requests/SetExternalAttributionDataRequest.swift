//
//  SetExternalAttributionDataRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

struct SetExternalAttributionDataRequest: BackendEncodableRequest {
    let endpoint = HTTPEndpoint(
        method: .post,
        path: "/sdk/attribution/profile/set/data/"
    )
    let headers: HTTPHeaders
    let contentType: String? = "application/json"
    let stamp = Log.stamp
    let requestName = BackendRequestName.setExternalAttributionData
    let logParams: EventParameters?

    let provider: AdaptyExternalAttributionProvider
    let attributionJson: String
    let userId: AdaptyUserId

    init(userId: AdaptyUserId, provider: AdaptyExternalAttributionProvider, attributionJson: String, responseHash: String?) {
        headers = HTTPHeaders()
            .setUserProfileId(userId)
            .setBackendResponseHash(responseHash)

        self.provider = provider
        self.attributionJson = attributionJson
        self.userId = userId

        logParams = [
            "provider": provider,
        ]
    }

    enum CodingKeys: String, CodingKey {
        case provider = "source"
        case attributionJson = "attribution_json"
        case profileId = "profile_id"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(provider, forKey: .provider)
        try container.encode(attributionJson, forKey: .attributionJson)
        try container.encode(userId.profileId, forKey: .profileId)
    }
}

private typealias ResponseBody = AdaptyProfile?

extension Backend.MainExecutor {
    func setExternalAttributionData(
        userId: AdaptyUserId,
        provider: AdaptyExternalAttributionProvider,
        attributionJson: String,
        responseHash: String?
    ) async throws(HTTPError) -> VH<AdaptyProfile>? {
        let request = SetExternalAttributionDataRequest(
            userId: userId,
            provider: provider,
            attributionJson: attributionJson,
            responseHash: responseHash
        )
        let response = try await perform(request, withDecoder: VH<AdaptyProfile>?.decoder)
        return response.body
    }
}
