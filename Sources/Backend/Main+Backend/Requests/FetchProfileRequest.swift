//
//  FetchProfileRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

private struct FetchProfileRequest: BackendRequest {
    let endpoint: HTTPEndpoint
    let headers: HTTPHeaders
    let stamp = Log.stamp
    let logName = APIRequestName.fetchProfile

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

extension Backend.MainExecutor {
    func fetchProfile(
        userId: AdaptyUserId,
        responseHash: String?
    ) async throws(HTTPError) -> VH<AdaptyProfile>? {
        let request = FetchProfileRequest(
            userId: userId,
            responseHash: responseHash
        )
        let response = try await perform(request, withDecoder: VH<AdaptyProfile>?.decoder)
        return response.body
    }
}
