//
//  FetchProfileRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

private struct FetchProfileRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = AdaptyProfile?
    let endpoint: HTTPEndpoint
    let headers: HTTPHeaders
    let stamp = Log.stamp

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

    init(profileId: String, responseHash: String?) {
        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/analytics/profiles/\(profileId)/"
        )

        headers = HTTPHeaders()
            .setBackendProfileId(profileId)
            .setBackendResponseHash(responseHash)
    }
}

extension HTTPRequestWithDecodableResponse where ResponseBody == AdaptyProfile? {
    @inlinable
    static func decodeResponse(
        _ response: HTTPDataResponse,
        withConfiguration configuration: HTTPCodableConfiguration?,
        requestHeaders: HTTPHeaders
    ) throws -> HTTPResponse<AdaptyProfile?> {
        guard !requestHeaders.hasSameBackendResponseHash(response.headers) else {
            return response.replaceBody(nil)
        }

        let jsonDecoder = JSONDecoder()
        configuration?.configure(jsonDecoder: jsonDecoder)

        let body: ResponseBody = try jsonDecoder.decode(
            Backend.Response.Data<AdaptyProfile>.self,
            responseBody: response.body
        ).value

        return response.replaceBody(body)
    }
}

extension Backend.MainExecutor {
    func fetchProfile(
        profileId: String,
        responseHash: String?
    ) async throws -> VH<AdaptyProfile?> {
        let request = FetchProfileRequest(
            profileId: profileId,
            responseHash: responseHash
        )

        let response = try await perform(
            request,
            requestName: .fetchProfile
        )

        return VH(response.body, hash: response.headers.getBackendResponseHash())
    }
}
