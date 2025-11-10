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

    init(userId: AdaptyUserId, responseHash: String?) {
        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/analytics/profiles/\(userId.profileId)/"
        )

        headers = HTTPHeaders()
            .setUserProfileId(userId)
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

extension Backend.DefaultExecutor {
    func fetchProfile(
        userId: AdaptyUserId,
        responseHash: String?
    ) async throws(HTTPError) -> VH<AdaptyProfile>? {
        let request = FetchProfileRequest(
            userId: userId,
            responseHash: responseHash
        )

        let response = try await perform(
            request,
            requestName: .fetchProfile
        )

        guard let profile = response.body else { return nil }
        return VH(profile, hash: response.headers.getBackendResponseHash())
    }
}
