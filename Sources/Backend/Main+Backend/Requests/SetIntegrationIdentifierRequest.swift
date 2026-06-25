//
//  SetIntegrationIdentifierRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import AdaptyCodable
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

    init(userId: AdaptyUserId, identifiers: [AdaptyIntegrationIdentifier]) {
        headers = HTTPHeaders()
            .setUserProfileId(userId)

        let identifiers = identifiers.asDictionary
        self.userId = userId
        keyValues = identifiers
        logParams = identifiers
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
        identifiers: [AdaptyIntegrationIdentifier]
    ) async throws(HTTPError) {
        let request = SetIntegrationIdentifierRequest(
            userId: userId,
            identifiers: identifiers
        )
        let _: HTTPEmptyResponse = try await perform(request)
    }
}
