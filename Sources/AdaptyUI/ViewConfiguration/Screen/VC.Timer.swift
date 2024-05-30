//
//  VC.Timer.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct Timer {
        let id: String
        let duration: TimeInterval
        let startBehaviour: AdaptyUI.Timer.StartBehaviour
        let format: [Item]
        let defaultTextAttributes: TextAttributes?

        struct Item {
            let from: TimeInterval
            let stringId: String
        }
    }
}

extension AdaptyUI.ViewConfiguration.Localizer {
    func timer(_ from: AdaptyUI.ViewConfiguration.Timer) -> AdaptyUI.Timer {
        AdaptyUI.Timer(
            id: from.id,
            duration: from.duration,
            startBehaviour: from.startBehaviour,
            format: from.format.compactMap {
                guard let value = richText(
                    stringId: $0.stringId,
                    defaultTextAttributes: from.defaultTextAttributes,
                    defaultParagraphAttributes: nil
                ) else { return nil }

                return AdaptyUI.Timer.Item(
                    from: $0.from,
                    value: value
                )
            }
        )
    }
}

extension AdaptyUI.ViewConfiguration.Timer: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case duration
        case startBehaviour = "start_behaviour"
        case format
        case startTime = "start_time"
    }

    enum StartBehaviourType: String, Codable {
        case everyAppear = "every_appear"
        case firstAppear = "first_appear"
        case firstAppearPersisted = "first_appear_persisted"
        case specifiedTime = "specified_time"
        case custom
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        duration = try container.decode(TimeInterval.self, forKey: .duration)
        startBehaviour =
            if let startBehaviour = try container.decodeIfPresent(String.self, forKey: .startBehaviour) {
                switch StartBehaviourType(rawValue: startBehaviour) {
                case .none:
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath + [CodingKeys.startBehaviour], debugDescription: "unknown value '\(startBehaviour)'"))
                case .everyAppear:
                    .everyAppear
                case .firstAppear:
                    .firstAppear
                case .firstAppearPersisted:
                    .firstAppearPersisted
                case .custom:
                    .custom
                case .specifiedTime:
                    try .specifiedTime(Date(timeIntervalSince1970: TimeInterval(container.decode(Int64.self, forKey: .startTime)) / 1000))
                }
            } else {
                AdaptyUI.Timer.defaultStartBehaviour
            }

        format =
            if let stringId = try? container.decode(String.self, forKey: .format) {
                [.init(from: 0, stringId: stringId)]
            } else {
                try container.decode([Item].self, forKey: .format)
            }

        let textAttributes = try AdaptyUI.ViewConfiguration.TextAttributes(from: decoder)
        defaultTextAttributes = textAttributes.isEmpty ? nil : textAttributes
    }
}

extension AdaptyUI.ViewConfiguration.Timer.Item: Decodable {
    enum CodingKeys: String, CodingKey {
        case from
        case stringId = "string_id"
    }
}
