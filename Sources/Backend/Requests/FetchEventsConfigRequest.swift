//
//  FetchEventsConfigRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

struct FetchEventsConfigRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.ValueOfData<EventsBackendConfiguration>

    let endpoint = HTTPEndpoint(
        method: .get,
        path: "/sdk/events/blacklist/"
    )
    let headers: Headers

    init(profileId: String) {
        headers = Headers().setBackendProfileId(profileId)
    }
}
