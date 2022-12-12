//
//  SendEventsRequest.swift
//  Adapty
//
//  Created by Aleksei Valiano on 13.10.2022.
//

import Foundation

struct SendEventsRequest: HTTPEncodableRequest {
    typealias Result = HTTPEmptyResponse.Result

    let endpoint = HTTPEndpoint(
        method: .post,
        path: ""
    )
    let events: [Data]
    let streamName: String

    init(events: [Data], streamName: String) {
        self.events = events
        self.streamName = streamName
    }

    enum CodingKeys: String, CodingKey {
        case records = "Records"
        case streamName = "StreamName"
    }

    enum RecordCodingKeys: String, CodingKey {
        case data = "Data"
        case partitionKey = "PartitionKey"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var records = container.nestedUnkeyedContainer(forKey: .records)
        try events.forEach { event in
            var record = records.nestedContainer(keyedBy: RecordCodingKeys.self)
            try record.encode(event, forKey: .data)
            try record.encode(Environment.Application.installationIdentifier, forKey: .partitionKey)
        }
        try container.encode(streamName, forKey: .streamName)
    }
}
