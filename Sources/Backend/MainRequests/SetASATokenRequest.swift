//
//  SetASATokenRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.03.2024.
//

import Foundation

private struct SetASATokenRequest: HTTPEncodableRequest, HTTPRequestWithDecodableResponse {
    typealias ResponseBody = AdaptyProfile?
    let endpoint = HTTPEndpoint(
        method: .post,
        path: "/sdk/attribution/asa/"
    )
    let headers: HTTPHeaders
    let stamp = Log.stamp

    let token: String

    func decodeDataResponse(
        response: HTTPDataResponse,
        withConfiguration configuration: HTTPCodableConfiguration?
    ) throws -> Response {
        try Self.decodeResponse(
            response,
            withConfiguration: configuration,
            requestHeaders: headers
        )
    }

    init(profileId: String, token: String, responseHash: String?) {
        headers = HTTPHeaders()
            .setBackendProfileId(profileId)
            .setBackendResponseHash(responseHash)

        self.token = token
    }

    enum CodingKeys: String, CodingKey {
        case token
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Backend.CodingKeys.self)
        var dataObject = container.nestedContainer(keyedBy: Backend.CodingKeys.self, forKey: .data)
        try dataObject.encode("adapty_attribution_asa", forKey: .type)
        var attributesObject = dataObject.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributes)
        try attributesObject.encode(token, forKey: .token)
    }
}

extension Backend.MainExecutor {
    func performSendASATokenRequest(
        profileId: String,
        token: String,
        responseHash: String?
    ) async throws -> VH<AdaptyProfile?> {
        let request = SetASATokenRequest(
            profileId: profileId,
            token: token,
            responseHash: responseHash
        )
        let response = try await perform(
            request,
            requestName: .sendASAToken,
            logParams: ["token": token]
        )

        return VH(response.body, hash: response.headers.getBackendResponseHash())
    }
}
