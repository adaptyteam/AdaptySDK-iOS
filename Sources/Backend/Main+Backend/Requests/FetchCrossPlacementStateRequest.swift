//
//  FetchCrossPlacementStateRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.04.2025.
//

import Foundation

private struct FetchCrossPlacementStateRequest: BackendRequest {
    let endpoint = HTTPEndpoint(
        method: .get,
        path: "/sdk/in-apps/profile/cross-placement-info/"
    )
    let headers: HTTPHeaders
    let stamp = Log.stamp
    let logName = APIRequestName.fetchCrossPlacementState

    init(userId: AdaptyUserId) {
        headers = HTTPHeaders()
            .setUserProfileId(userId)
    }
}

private typealias ResponseBody = Backend.Response.Data<CrossPlacementState>

extension Backend.MainExecutor {
    func fetchCrossPlacementState(
        userId: AdaptyUserId
    ) async throws(HTTPError) -> CrossPlacementState {
        let request = FetchCrossPlacementStateRequest(
            userId: userId
        )
        let response: HTTPResponse<ResponseBody> = try await perform(request)
        return response.body.value
    }
}
