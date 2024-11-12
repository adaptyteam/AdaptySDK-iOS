//
//  VC.Box.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension AdaptyViewSource {
    struct Box: Sendable, Hashable {
        let width: AdaptyViewConfiguration.Box.Length?
        let height: AdaptyViewConfiguration.Box.Length?
        let horizontalAlignment: AdaptyViewConfiguration.HorizontalAlignment
        let verticalAlignment: AdaptyViewConfiguration.VerticalAlignment
        let content: AdaptyViewSource.Element?
    }
}

extension AdaptyViewSource.Localizer {
    func box(_ from: AdaptyViewSource.Box) throws -> AdaptyViewConfiguration.Box {
        try .init(
            width: from.width,
            height: from.height,
            horizontalAlignment: from.horizontalAlignment,
            verticalAlignment: from.verticalAlignment,
            content: from.content.map(element)
        )
    }
}

extension AdaptyViewSource.Box: Decodable {
    enum CodingKeys: String, CodingKey {
        case width
        case height
        case horizontalAlignment = "h_align"
        case verticalAlignment = "v_align"
        case content
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            width: try? container.decodeIfPresent(AdaptyViewConfiguration.Box.Length.self, forKey: .width),
            height: try? container.decodeIfPresent(AdaptyViewConfiguration.Box.Length.self, forKey: .height),
            horizontalAlignment: container.decodeIfPresent(AdaptyViewConfiguration.HorizontalAlignment.self, forKey: .horizontalAlignment) ?? AdaptyViewConfiguration.Box.defaultHorizontalAlignment,
            verticalAlignment: container.decodeIfPresent(AdaptyViewConfiguration.VerticalAlignment.self, forKey: .verticalAlignment) ?? AdaptyViewConfiguration.Box.defaultVerticalAlignment,
            content: container.decodeIfPresent(AdaptyViewSource.Element.self, forKey: .content)
        )
    }
}

extension AdaptyViewConfiguration.Box.Length: Decodable {
    enum CodingKeys: String, CodingKey {
        case min
        case shrink
        case fillMax = "fill_max"
    }

    package init(from decoder: Decoder) throws {
        if let value = try? decoder.singleValueContainer().decode(AdaptyViewConfiguration.Unit.self) {
            self = .fixed(value)
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let value = try container.decodeIfPresent(Bool.self, forKey: .fillMax), value {
                self = .fillMax
            } else if let value = try container.decodeIfPresent(AdaptyViewConfiguration.Unit.self, forKey: .min) {
                self = .min(value)
            } else if let value = try container.decodeIfPresent(AdaptyViewConfiguration.Unit.self, forKey: .shrink) {
                self = .shrink(value)
            } else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "don't found fill_max:true or min"))
            }
        }
    }
}
