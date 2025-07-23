//
//  SetIntegrationIdentifierRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

private struct SetIntegrationIdentifierRequest: HTTPEncodableRequest {
    typealias ResponseBody = AdaptyProfile?
    let endpoint = HTTPEndpoint(
        method: .post,
        path: "/sdk/integration/profile/set/integration-identifiers/"
    )

    let headers: HTTPHeaders
    let contentType: String? = "application/json"

    let stamp = Log.stamp

    let profileId: String
    let keyValues: [String: String]

    init(profileId: String, keyValues: [String: String]) {
        headers = HTTPHeaders()
            .setBackendProfileId(profileId)

        self.profileId = profileId
        self.keyValues = keyValues
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Backend.CodingKeys.self)
        var keyValues = keyValues
        keyValues["profile_id"] = profileId
        try container.encode(keyValues, forKey: .data)
    }
}

extension Backend.MainExecutor {
    func setIntegrationIdentifier(
        profileId: String,
        keyValues: [String: String]
    ) async throws(HTTPError) {
        let request = SetIntegrationIdentifierRequest(
            profileId: profileId,
            keyValues: keyValues
        )
        let _: HTTPEmptyResponse = try await perform(
            request,
            requestName: .setIntegrationIdentifier,
            logParams: keyValues
        )
    }
}
