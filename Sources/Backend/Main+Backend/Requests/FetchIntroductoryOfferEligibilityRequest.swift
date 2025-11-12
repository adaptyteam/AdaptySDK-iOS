//
//  FetchIntroductoryOfferEligibilityRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

private struct FetchIntroductoryOfferEligibilityRequest: BackendRequest {
    let endpoint = HTTPEndpoint(
        method: .get,
        path: "/sdk/in-apps/products/"
    )
    let headers: HTTPHeaders
    let queryItems: QueryItems
    let stamp = Log.stamp
    let logName = APIRequestName.fetchProductStates

    init(userId: AdaptyUserId, responseHash: String?) {
        headers = HTTPHeaders()
            .setUserProfileId(userId)
            .setBackendResponseHash(responseHash)

        queryItems = QueryItems()
            .setUserProfileId(userId)
    }
}

extension Backend.MainExecutor {
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
            withDecoder: [BackendIntroductoryOfferEligibilityState]?.decoder
        )
        return VH(response.body ?? [], hash: response.headers.getBackendResponseHash())
    }
}
