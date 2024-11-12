//
//  VC.Box.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension AdaptyUICore.ViewConfiguration {
    struct Box: Sendable, Hashable {
        let width: AdaptyUICore.Box.Length?
        let height: AdaptyUICore.Box.Length?
        let horizontalAlignment: AdaptyUICore.HorizontalAlignment
        let verticalAlignment: AdaptyUICore.VerticalAlignment
        let content: AdaptyUICore.ViewConfiguration.Element?
    }
}

extension AdaptyUICore.ViewConfiguration.Localizer {
    func box(_ from: AdaptyUICore.ViewConfiguration.Box) throws -> AdaptyUICore.Box {
        try .init(
            width: from.width,
            height: from.height,
            horizontalAlignment: from.horizontalAlignment,
            verticalAlignment: from.verticalAlignment,
            content: from.content.map(element)
        )
    }
}

extension AdaptyUICore.ViewConfiguration.Box: Decodable {
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
            width: try? container.decodeIfPresent(AdaptyUICore.Box.Length.self, forKey: .width),
            height: try? container.decodeIfPresent(AdaptyUICore.Box.Length.self, forKey: .height),
            horizontalAlignment: container.decodeIfPresent(AdaptyUICore.HorizontalAlignment.self, forKey: .horizontalAlignment) ?? AdaptyUICore.Box.defaultHorizontalAlignment,
            verticalAlignment: container.decodeIfPresent(AdaptyUICore.VerticalAlignment.self, forKey: .verticalAlignment) ?? AdaptyUICore.Box.defaultVerticalAlignment,
            content: container.decodeIfPresent(AdaptyUICore.ViewConfiguration.Element.self, forKey: .content)
        )
    }
}

extension AdaptyUICore.Box.Length: Decodable {
    enum CodingKeys: String, CodingKey {
        case min
        case shrink
        case fillMax = "fill_max"
    }

    package init(from decoder: Decoder) throws {
        if let value = try? decoder.singleValueContainer().decode(AdaptyUICore.Unit.self) {
            self = .fixed(value)
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let value = try container.decodeIfPresent(Bool.self, forKey: .fillMax), value {
                self = .fillMax
            } else if let value = try container.decodeIfPresent(AdaptyUICore.Unit.self, forKey: .min) {
                self = .min(value)
            } else if let value = try container.decodeIfPresent(AdaptyUICore.Unit.self, forKey: .shrink) {
                self = .shrink(value)
            } else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "don't found fill_max:true or min"))
            }
        }
    }
}
