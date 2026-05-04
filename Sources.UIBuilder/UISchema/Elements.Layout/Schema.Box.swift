//
//  Schema.Box.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    struct Box: Sendable {
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

extension Schema.Box: Schema.CompositeElement {
    @inlinable
    func planTasks(in taskStack: inout Schema.ConfigurationBuilder.TasksStack) {
        if let content {
            taskStack.append(.planElement(content))
        }
    }

    @inlinable
    func buildElement(
        _ builder: Schema.ConfigurationBuilder,
        _ properties: VC.Element.Properties?,
        _ elementIndices: inout [VC.ElementIndex]
    ) throws(Schema.Error) -> VC.Element {
        try .box(
            builder.buildBox(self, &elementIndices),
            properties
        )
    }
}

extension Schema.ConfigurationBuilder {
    @inlinable
    func buildBox(
        _ from: Schema.Box,
        _ elementIndices: inout [VC.ElementIndex]
    ) throws(Schema.Error) -> VC.Box {
        try .init(
            width: from.width,
            height: from.height,
            horizontalAlignment: from.horizontalAlignment,
            verticalAlignment: from.verticalAlignment,
            content: elementIndices.pop(from.content != nil)
        )
    }
}

extension Schema.Box: DecodableWithConfiguration {
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
            content: container.decodeIfExist(Schema.Element.self, forKey: .content, configuration: configuration)
        )
    }
}
