//
//  SendEventsRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 13.10.2022.
//

import Foundation

struct SendEventsRequest: HTTPDataRequest {
    let endpoint = HTTPEndpoint(
        method: .post,
        path: "/sdk/events/"
    )
    let headers: HTTPHeaders
    let stamp = Log.stamp

    let events: [Data]

    init(userId: AdaptyUserId, events: [Data]) {
        headers = HTTPHeaders().setUserProfileId(userId)
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
        static let suffix = "]}}}".data(using: .utf8)!
    }

    func getData(configuration _: HTTPConfiguration) throws -> Data? {
        var data = Data()
        data.append(Constants.prefix)
        data.append(contentsOf: events.joined(separator: Constants.separator))
        data.append(Constants.suffix)
        return data
    }
}

extension Backend.EventsExecutor {
    func sendEvents(
        userId: AdaptyUserId,
        events: [Data]
    ) async throws(EventsError) {
        do {
            let _: HTTPEmptyResponse = try await session.perform(SendEventsRequest(
                userId: userId,
                events: events
            ))
        } catch {
            throw EventsError.sending(error)
        }
    }
}
