//
//  SendEventsRequest.swift
//  Adapty
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

    func getData(configuration: HTTPConfiguration) throws -> Data? {
        let separator = ",".data(using: .utf8)!
        let data = NSMutableData(data: "{\"\(CodingKeys.events.stringValue)\":[".data(using: .utf8)!)
        var count = events.count
        events.forEach {
            data.append($0)
            count -= 1
            if count > 0 {
                data.append(separator)
            }
        }
        data.append("]}".data(using: .utf8)!)

        return data as Data
    }
}
