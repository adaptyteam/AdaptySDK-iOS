//
//  Schema.Box.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    struct Box: Sendable, Hashable {
        let width: Length?
        let height: Length?
        let horizontalAlignment: HorizontalAlignment
        let verticalAlignment: VerticalAlignment
        let content: Schema.Element?
    }
}

extension Schema.Box {
    static let `default` = (
        horizontalAlignment: VC.HorizontalAlignment.center,
        verticalAlignment: VC.VerticalAlignment.center
    )
}

extension Schema.ConfigurationBuilder {
    @inlinable
    func planBox(
        _ value: Schema.Box,
        _ properties: VC.Element.Properties?,
        in taskStack: inout [Task]
    ) {
        taskStack.append(.buildBox(value, properties))
        if let content = value.content {
            taskStack.append(.planElement(content))
        }
    }

    @inlinable
    func buildBox(
        _ from: Schema.Box,
        _ elementStack: inout [VC.Element]
    ) throws(Schema.Error) -> VC.Box {
        let content = try elementStack.popLastElement(from.content != nil)
        return .init(
            width: from.width,
            height: from.height,
            horizontalAlignment: from.horizontalAlignment,
            verticalAlignment: from.verticalAlignment,
            content: content
        )
    }
}

extension Schema.Box: Encodable, DecodableWithConfiguration {
    enum CodingKeys: String, CodingKey {
        case width
        case height
        case horizontalAlignment = "h_align"
        case verticalAlignment = "v_align"
        case content
    }

    init(from decoder: Decoder, configuration: Schema.DecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            width: try? container.decodeIfPresent(Length.self, forKey: .width),
            height: try? container.decodeIfPresent(Length.self, forKey: .height),
            horizontalAlignment: container.decodeIfPresent(Schema.HorizontalAlignment.self, forKey: .horizontalAlignment) ?? Self.default.horizontalAlignment,
            verticalAlignment: container.decodeIfPresent(Schema.VerticalAlignment.self, forKey: .verticalAlignment) ?? Self.default.verticalAlignment,
            content: container.decodeIfPresent(Schema.Element.self, forKey: .content, configuration: configuration)
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
