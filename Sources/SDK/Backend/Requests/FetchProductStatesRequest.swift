//
//  FetchProductStatesRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

private struct FetchProductStatesRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = [BackendProductState]?
    let endpoint = HTTPEndpoint(
        method: .get,
        path: "/sdk/in-apps/products/"
    )
    let headers: HTTPHeaders
    let queryItems: QueryItems
    let stamp = Log.stamp

    func decodeDataResponse(
        _ response: HTTPDataResponse,
        withConfiguration configuration: HTTPCodableConfiguration?
    ) throws -> Response {
        try Self.decodeDataResponse(
            response,
            withConfiguration: configuration,
            requestHeaders: headers
        )
    }

    init(profileId: String, responseHash: String?) {
        headers = HTTPHeaders()
            .setBackendProfileId(profileId)
            .setBackendResponseHash(responseHash)
        queryItems = QueryItems().setBackendProfileId(profileId)
    }
}

extension HTTPRequestWithDecodableResponse where ResponseBody == [BackendProductState]? {
    @inlinable
    static func decodeDataResponse(
        _ response: HTTPDataResponse,
        withConfiguration configuration: HTTPCodableConfiguration?,
        requestHeaders: HTTPHeaders
    ) throws -> HTTPResponse<[BackendProductState]?> {
        guard !requestHeaders.hasSameBackendResponseHash(response.headers) else {
            return response.replaceBody(nil)
        }

        let jsonDecoder = JSONDecoder()
        configuration?.configure(jsonDecoder: jsonDecoder)

        let body: [BackendProductState]? = try jsonDecoder.decode(
            Backend.Response.ValueOfData<[BackendProductState]>.self,
            responseBody: response.body
        ).value
        return response.replaceBody(body)
    }
}

extension HTTPSession {
    func performFetchProductStatesRequest(
        profileId: String,
        responseHash: String?
    ) async throws -> VH<[BackendProductState]?> {
        let request = FetchProductStatesRequest(
            profileId: profileId,
            responseHash: responseHash
        )

        let response = try await perform(
            request,
            requestName: .fetchProductStates
        )
        return VH(response.body, hash: response.headers.getBackendResponseHash())
    }
}
