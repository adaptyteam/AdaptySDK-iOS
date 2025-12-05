//
//  Schema.Element.Properties.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.11.2025.
//

import Foundation

extension Schema.Element {
    struct Properties: Sendable, Hashable {
        let legacyElementId: String?
        let decorator: Schema.Decorator?
        let padding: Schema.EdgeInsets
        let offset: Schema.Offset

        let opacity: Double
        let onAppear: [Schema.Animation]
    }
}

extension Schema.Element.Properties {
    var isZero: Bool {
        legacyElementId == nil
            && decorator == nil
            && padding.isZero
            && offset.isZero
            && opacity == 0
            && onAppear.isEmpty
    }
}

extension Schema.Element.Properties {
    static let `default` = VC.Element.Properties.default
}

extension Schema.Localizer {
    func elementProperties(_ from: Schema.Element.Properties) throws -> VC.Element.Properties? {
        guard !from.isZero else { return nil }
        return try .init(
            decorator: from.decorator.map(decorator),
            padding: from.padding,
            offset: from.offset,
            opacity: from.opacity,
            onAppear: from.onAppear.map(animation)
        )
    }
}

extension Schema.Element.Properties: Decodable {
    enum CodingKeys: String, CodingKey {
        case legacyElementId = "element_id"
        case decorator
        case padding
        case offset
        case visibility
        case opacity
        case transitionIn = "transition_in"
        case onAppear = "on_appear"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let onAppear: [Schema.Animation] =
            if container.contains(.transitionIn), !container.contains(.onAppear) {
                if let animation = try container.decodeIfPresent(Schema.Animation.self, forKey: .transitionIn) { [animation] } else { [] }
            } else {
                if let array = try? container.decodeIfPresent([Schema.Animation].self, forKey: .onAppear) {
                    array
                } else { [] }
            }

        let opacity = if container.contains(.visibility), !container.contains(.opacity) {
            try container.decodeIfPresent(Bool.self, forKey: .visibility) ?? true ? 1.0 : 0.0
        } else {
            try container.decodeIfPresent(Double.self, forKey: .opacity) ?? Self.default.opacity
        }

        try self.init(
            legacyElementId: container.decodeIfPresent(String.self, forKey: .legacyElementId),
            decorator: container.decodeIfPresent(Schema.Decorator.self, forKey: .decorator),
            padding: container.decodeIfPresent(Schema.EdgeInsets.self, forKey: .padding) ?? Self.default.padding,
            offset: container.decodeIfPresent(Schema.Offset.self, forKey: .offset) ?? Self.default.offset,
            opacity: opacity,
            onAppear: onAppear
        )
    }
}
