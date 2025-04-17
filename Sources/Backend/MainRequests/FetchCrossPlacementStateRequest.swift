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

    init(profileId: String) {
        headers = HTTPHeaders()
            .setBackendProfileId(profileId)
    }
}

extension Backend.MainExecutor {
    func fetchCrossPlacementState(
        profileId: String
    ) async throws -> CrossPlacementState {
        let request = FetchCrossPlacementStateRequest(
            profileId: profileId
        )

        let response = try await perform(
            request,
            requestName: .fetchCrossPlacementState
        )

        return response.body.value
    }
}
