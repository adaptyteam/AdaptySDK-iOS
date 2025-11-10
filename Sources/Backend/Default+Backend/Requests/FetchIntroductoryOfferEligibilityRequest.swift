//
//  FetchIntroductoryOfferEligibilityRequest.swift
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

    init(userId: AdaptyUserId, responseHash: String?) {
        headers = HTTPHeaders()
            .setUserProfileId(userId)
            .setBackendResponseHash(responseHash)

        queryItems = QueryItems()
            .setUserProfileId(userId)
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

extension Backend.DefaultExecutor {
    func fetchIntroductoryOfferEligibility(
        userId: AdaptyUserId,
        responseHash: String?
    ) async throws(HTTPError) -> VH<[BackendIntroductoryOfferEligibilityState]> {
        let request = FetchIntroductoryOfferEligibilityRequest(
            userId: userId,
            responseHash: responseHash
        )

        let response = try await perform(
            request,
            requestName: .fetchProductStates
        )
        return VH(response.body ?? [], hash: response.headers.getBackendResponseHash())
    }
}
