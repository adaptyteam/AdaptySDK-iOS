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

    init(profileId: String) {
        headers = HTTPHeaders().setBackendProfileId(profileId)
    }
}

extension Backend.EventsExecutor {
    func fetchEventsConfig(
        profileId: String
    ) async throws -> EventsBackendConfiguration {
        do {
            let request = FetchEventsConfigRequest(
                profileId: profileId
            )

            let response = try await perform(
                request,
                requestName: .fetchEventsConfig
            )
            return response.body.value

        } catch {
            throw EventsError.sending(error)
        }
    }
}
