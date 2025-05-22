//
//  VC.Box.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 28.03.2024
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

extension AdaptyViewSource.Box: Codable {
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

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(width, forKey: .width)
        try container.encodeIfPresent(height, forKey: .height)
        if horizontalAlignment != .center {
            try container.encode(horizontalAlignment, forKey: .horizontalAlignment)
        }
        if verticalAlignment != .center {
            try container.encode(verticalAlignment, forKey: .verticalAlignment)
        }
        try container.encodeIfPresent(content, forKey: .content)
    }
}

extension AdaptyViewConfiguration.Box.Length: Codable {
    enum CodingKeys: String, CodingKey {
        case min
        case max
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
                self = try .flexible(min: value, max: container.decodeIfPresent(AdaptyViewConfiguration.Unit.self, forKey: .max))
            } else if let value = try container.decodeIfPresent(AdaptyViewConfiguration.Unit.self, forKey: .shrink) {
                self = try .shrinkable(min: value, max: container.decodeIfPresent(AdaptyViewConfiguration.Unit.self, forKey: .max))
            } else if let value = try container.decodeIfPresent(AdaptyViewConfiguration.Unit.self, forKey: .max) {
                self = .flexible(min: nil, max: value)
            } else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "don't found unknown properties"))
            }
        }
    }

    package func encode(to encoder: any Encoder) throws {
        switch self {
        case let .fixed(unit):
            try unit.encode(to: encoder)
        case let .flexible(min, max):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(min, forKey: .min)
            try container.encodeIfPresent(max, forKey: .max)
        case let .shrinkable(min, max):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(min, forKey: .shrink)
            try container.encodeIfPresent(max, forKey: .max)
        case .fillMax:
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(true, forKey: .fillMax)
        }
    }
}
