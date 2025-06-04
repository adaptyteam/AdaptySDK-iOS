//
//  FetchProductStatesRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

private struct FetchIntroductoryOfferEligibilityRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = [BackendIntroductoryOfferEligibilityState]?
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
        try Self.decodeResponse(
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

extension HTTPRequestWithDecodableResponse where ResponseBody == [BackendIntroductoryOfferEligibilityState]? {
    @inlinable
    static func decodeResponse(
        _ response: HTTPDataResponse,
        withConfiguration configuration: HTTPCodableConfiguration?,
        requestHeaders: HTTPHeaders
    ) throws -> HTTPResponse<[BackendIntroductoryOfferEligibilityState]?> {
        guard !requestHeaders.hasSameBackendResponseHash(response.headers) else {
            return response.replaceBody(nil)
        }

        let jsonDecoder = JSONDecoder()
        configuration?.configure(jsonDecoder: jsonDecoder)

        let body: [BackendIntroductoryOfferEligibilityState]? = try jsonDecoder.decode(
            Backend.Response.Data<[BackendIntroductoryOfferEligibilityState]>.self,
            responseBody: response.body
        ).value
        return response.replaceBody(body)
    }
}

extension Backend.MainExecutor {
    func fetchIntroductoryOfferEligibility(
        profileId: String,
        responseHash: String?
    ) async throws -> VH<[BackendIntroductoryOfferEligibilityState]?> {
        let request = FetchIntroductoryOfferEligibilityRequest(
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
