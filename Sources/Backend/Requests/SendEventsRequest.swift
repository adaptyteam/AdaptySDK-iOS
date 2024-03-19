//
//  SendEventsRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 13.10.2022.
//

import Foundation

struct SendEventsRequest: HTTPDataRequest {
    typealias Result = HTTPEmptyResponse.Result

    let endpoint = HTTPEndpoint(
        method: .post,
        path: "/sdk/events/"
    )
    let events: [Data]
    let headers: Headers

    init(profileId: String, events: [Data]) {
        headers = Headers().setBackendProfileId(profileId)
        self.events = events
    }

    enum CodingKeys: String, CodingKey {
        case events
    }

    private enum Constants {
        static let prefix = [
            "{", Backend.CodingKeys.data.stringValue,
            ":{", Backend.CodingKeys.type.stringValue,
            ":", "sdk_background_event",
            ",", Backend.CodingKeys.attributes.stringValue,
            ":{", CodingKeys.events.stringValue, ":[",
        ].joined(separator: "\"").data(using: .utf8)!

        static let separator = ",".data(using: .utf8)!
        static let sufix = "]}}}".data(using: .utf8)!
    }

    func getData(configuration _: HTTPConfiguration) throws -> Data? {
        var data = Data()
        data.append(Constants.prefix)
        data.append(contentsOf: events.joined(separator: Constants.separator))
        data.append(Constants.sufix)
        return data
    }
}
