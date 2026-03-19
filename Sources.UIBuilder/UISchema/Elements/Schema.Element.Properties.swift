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
        let background: [Schema.Element]?
        let overlay: [Schema.Element]?
        let value: VC.Element.Properties?
    }
}

extension Schema.Element.Properties {
    static let `default` = (
        padding: VC.EdgeInsets.zero,
        offset: VC.Offset.zero,
        opacity: 1.0
    )
}

// extension Schema.ConfigurationBuilder {
//    @inlinable
//    func planElementProperties(
//        _ from: Schema.Element.Properties,
//        in taskStack: inout [Task]
//    ) {
//        if let background = from.background {
//            for el in background.reversed() {
//                taskStack.append(.planElement(el))
//            }
//        }
//        if let overlay = from.overlay {
//            for el in overlay.reversed() {
//                taskStack.append(.planElement(el))
//            }
//        }
//    }
//
//    @inlinable
//    func buildElementProperties(
//        _ from: Schema.Element.Properties,
//        _ elementStack: inout [VC.Element]
//    ) throws(Schema.Error) -> VC.Element.Properties {
//
//        if let background = from.background {
//            try elementStack.popLastElements(background.count)
//        }
//        if let overlay = from.overlay {
//            try elementStack.popLastElements(overlay.count)
//        }
//
//        let content = try elementStack.popLastElements(from.content.count)
//        return .init(
//            pageWidth: from.pageWidth,
//            pageHeight: from.pageHeight,
//            pagePadding: from.pagePadding,
//            spacing: from.spacing,
//            content: content,
//            pageControl: from.pageControl,
//            animation: from.animation,
//            interactionBehavior: from.interactionBehavior
//        )
//    }
// }

extension Schema.Element.Properties: DecodableWithConfiguration {
    enum CodingKeys: String, CodingKey {
        case legacyElementId = "element_id"
        case decorator
        case padding
        case offset
        case visibility
        case opacity
        case transitionIn = "transition_in"
        case onAppear = "on_appear"
        case overlay
        case backgound
    }

    init(from decoder: Decoder, configuration: Schema.DecodingConfiguration) throws {
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

        let value = try VC.Element.Properties(
            decorator: container.decodeIfPresent(Schema.Decorator.self, forKey: .decorator),
            padding: container.decodeIfPresent(Schema.EdgeInsets.self, forKey: .padding) ?? Self.default.padding,
            offset: container.decodeIfPresent(Schema.Offset.self, forKey: .offset) ?? Self.default.offset,
            opacity: opacity,
            onAppear: onAppear
        )

        let overlay = try container.decodeIfPresent([Schema.Element].self, forKey: .overlay, configuration: configuration)
        let background = try container.decodeIfPresent([Schema.Element].self, forKey: .overlay, configuration: configuration)

        try self.init(
            legacyElementId: container.decodeIfPresent(String.self, forKey: .legacyElementId),
            background: background.isEmpty ? nil : background,
            overlay: overlay.isEmpty ? nil : overlay,
            value: value.isEmpty ? nil : value
        )
    }
}

