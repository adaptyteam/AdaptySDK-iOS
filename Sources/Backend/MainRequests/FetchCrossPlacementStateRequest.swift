//
//  FetchCrossPlacementStateRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.04.2025.
//

import Foundation

private struct FetchCrossPlacementStateRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.Data<CrossPlacementState>
    let endpoint = HTTPEndpoint(
        method: .get,
        path: "/sdk/in-apps/profile/cross-placement-info/"
    )
    let headers: HTTPHeaders
    let stamp = Log.stamp

    init(userId: AdaptyUserId) {
        headers = HTTPHeaders()
            .setUserProfileId(userId)
    }
}

extension Backend.MainExecutor {
    func fetchCrossPlacementState(
        userId: AdaptyUserId
    ) async throws(HTTPError) -> CrossPlacementState {
        let request = FetchCrossPlacementStateRequest(
            userId: userId
        )

        let response = try await perform(
            request,
            requestName: .fetchCrossPlacementState
        )

        return response.body.value
    }
}
