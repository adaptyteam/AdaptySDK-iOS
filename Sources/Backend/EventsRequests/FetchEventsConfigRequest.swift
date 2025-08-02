//
//  FetchEventsConfigRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

private struct FetchEventsConfigRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.Data<EventsBackendConfiguration>

    let endpoint = HTTPEndpoint(
        method: .get,
        path: "/sdk/events/blacklist/"
    )
    let headers: HTTPHeaders
    let stamp = Log.stamp

    init(userId: AdaptyUserId) {
        headers = HTTPHeaders().setUserProfileId(userId)
    }
}

extension Backend.EventsExecutor {
    func fetchEventsConfig(
        userId: AdaptyUserId
    ) async throws(HTTPError) -> EventsBackendConfiguration {
        let request = FetchEventsConfigRequest(
            userId: userId
        )

        let response = try await perform(
            request,
            requestName: .fetchEventsConfig
        )
        return response.body.value
    }
}
