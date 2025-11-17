//
//  SetIntegrationIdentifierRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

private struct SetIntegrationIdentifierRequest: BackendEncodableRequest {
    let endpoint = HTTPEndpoint(
        method: .post,
        path: "/sdk/integration/profile/set/integration-identifiers/"
    )

    let headers: HTTPHeaders
    let contentType: String? = "application/json"

    let stamp = Log.stamp
    let requestName = BackendRequestName.setIntegrationIdentifier
    let logParams: EventParameters?

    let userId: AdaptyUserId
    let keyValues: [String: String]

    init(userId: AdaptyUserId, keyValues: [String: String]) {
        headers = HTTPHeaders()
            .setUserProfileId(userId)

        self.userId = userId
        self.keyValues = keyValues

        logParams = keyValues
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Backend.CodingKeys.self)
        var keyValues = keyValues
        keyValues["profile_id"] = userId.profileId
        try container.encode(keyValues, forKey: .data)
    }
}

extension Backend.MainExecutor {
    func setIntegrationIdentifier(
        userId: AdaptyUserId,
        keyValues: [String: String]
    ) async throws(HTTPError) {
        let request = SetIntegrationIdentifierRequest(
            userId: userId,
            keyValues: keyValues
        )
        let _: HTTPEmptyResponse = try await perform(request)
    }
}
