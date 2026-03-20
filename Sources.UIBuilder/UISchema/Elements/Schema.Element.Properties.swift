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
        let background: [Schema.Element.Overlay]?
        let overlay: [Schema.Element.Overlay]?
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

extension Schema.ConfigurationBuilder {
    @inlinable
    func planElementProperties(
        _ from: Schema.Element.Properties?,
        in taskStack: inout TasksStack
    ) {
        guard let from else { return }
        if let array = from.background, array.isNotEmpty {
            for overlay in array.reversed() {
                taskStack.append(.planElement(overlay.content))
            }
        }
        if let array = from.overlay, array.isNotEmpty {
            for overlay in array.reversed() {
                taskStack.append(.planElement(overlay.content))
            }
        }
    }

    @inlinable
    func buildElementProperties(
        _ from: Schema.Element.Properties?,
        _ resultStack: inout ResultStack
    ) throws(Schema.Error) -> VC.Element.Properties? {
        guard let from else { return nil }

        var background: [VC.Element.Overlay]?
        if let array = from.background, array.isNotEmpty {
            background = try convertElementOverlays(
                array,
                resultStack.popLastElements(array.count)
            )
            if background.isEmpty {
                background = nil
            }
        }

        var overlay: [VC.Element.Overlay]?
        if let array = from.overlay, array.isNotEmpty {
            overlay = try convertElementOverlays(
                array,
                resultStack.popLastElements(array.count)
            )
            if overlay.isEmpty {
                overlay = nil
            }
        }

        guard background != nil || overlay != nil else {
            return from.value
        }

        return if let value = from.value {
            .init(
                decorator: value.decorator,
                padding: value.padding,
                offset: value.offset,
                opacity: value.opacity,
                background: background ?? [],
                overlay: overlay ?? [],
                onAppear: value.onAppear
            )
        } else {
            .init(
                decorator: nil,
                padding: Schema.Element.Properties.default.padding,
                offset: Schema.Element.Properties.default.offset,
                opacity: Schema.Element.Properties.default.opacity,
                background: background,
                overlay: overlay,
                onAppear: []
            )
        }
    }
}

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
        case background
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
            background: nil,
            overlay: nil,
            onAppear: onAppear
        )

        let overlay = try container.decodeIfPresent([Schema.Element.Overlay].self, forKey: .overlay, configuration: configuration)
        let background = try container.decodeIfPresent([Schema.Element.Overlay].self, forKey: .background, configuration: configuration)

        try self.init(
            legacyElementId: container.decodeIfPresent(String.self, forKey: .legacyElementId),
            background: background.isEmpty ? nil : background,
            overlay: overlay.isEmpty ? nil : overlay,
            value: value.isEmpty ? nil : value
        )
    }
}
