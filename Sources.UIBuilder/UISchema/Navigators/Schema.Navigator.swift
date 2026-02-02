//
//  Schema.Navigator.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 30.01.2026.
//

import Foundation

extension Schema {
    struct Navigator: Sendable, Hashable {
        let id: NavigatorIdentifier
        let background: AssetReference
        let content: Element
        let order: Int?
    }
}

extension Schema.Navigator {
    static let `default`: Self = .init(
        id: "default",
        background: .color(.black),
        content: .scrrenHolder,
        order: 0
    )
}

extension Schema.Localizer {
    func navigator(_ from: Schema.Navigator) throws -> VC.Navigator {
        try .init(
            id: from.id,
            background: from.background,
            content: element(from.content),
            order: from.order
        )
    }
}

extension Schema.Navigator: Encodable, DecodableWithConfiguration {
    enum CodingKeys: String, CodingKey {
        case background
        case content
        case order
    }

    init(from decoder: any Decoder, configuration: Schema.DecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let navigatorId =
            if let value = configuration.insideNavigatorId {
                value
            } else {
                throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unknown navigator id"))
            }

        try self.init(
            id: navigatorId,
            background: container.decodeIfPresent(Schema.AssetReference.self, forKey: .background) ?? Self.default.background,
            content: container.decodeIfPresent(Schema.Element.self, forKey: .content, configuration: configuration) ?? Self.default.content,
            order: container.decodeIfPresent(Int.self, forKey: .order)
        )
    }
}
