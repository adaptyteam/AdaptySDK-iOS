//
//  Schema.ElementProperties.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.11.2025.
//

import Foundation

extension Schema {
    struct ElementProperties: Sendable {
        let legacyElementId: String?
        let background: [Schema.AlignedElement]?
        let overlay: [Schema.AlignedElement]?
        let value: VC.Element.Properties?
    }
}

extension Schema.ElementProperties {
    static let `default` = (
        padding: VC.EdgeInsets.zero,
        transform: VC.AffineTransform.empty,
        opacity: 1.0
    )
}

extension Schema.ConfigurationBuilder {
    @inlinable
    func planElementProperties(
        _ from: Schema.ElementProperties?,
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
        _ from: Schema.ElementProperties?,
        _ resultStack: inout Schema.ConfigurationBuilder.ResultStack
    ) throws(Schema.Error) -> VC.Element.Properties? {
        guard let from else { return nil }

        var background: [VC.AlignedElement]?
        if let array = from.background, array.isNotEmpty {
            background = try convertAlignedElement(
                array,
                resultStack.popLastElements(array.count)
            )
            if background.isEmpty {
                background = nil
            }
        }

        var overlay: [VC.AlignedElement]?
        if let array = from.overlay, array.isNotEmpty {
            overlay = try convertAlignedElement(
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
                transform: value.transform,
                opacity: value.opacity,
                background: background ?? [],
                overlay: overlay ?? [],
                onAppear: value.onAppear,
                focusId: value.focusId,
                interactionEnabled: value.interactionEnabled
            )
        } else {
            .init(
                decorator: nil,
                padding: Schema.ElementProperties.default.padding,
                transform: Schema.ElementProperties.default.transform,
                opacity: Schema.ElementProperties.default.opacity,
                background: background,
                overlay: overlay,
                onAppear: [],
                focusId: nil,
                interactionEnabled: nil
            )
        }
    }
}

extension Schema.ElementProperties: DecodableWithConfiguration {
    enum CodingKeys: String, CodingKey {
        case legacyElementId = "element_id"
        case decorator
        case padding
        case offset
        case transform
        case visibility
        case opacity
        case transitionIn = "transition_in"
        case onAppear = "on_appear"
        case overlay
        case background
        case focusId = "focus_id"
        case interactionEnabled = "ui_enabled"
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

        let transform =
            if container.contains(.transform) {
                try container.decode(Schema.AffineTransform.self, forKey: .transform)
            } else if container.contains(.offset) {
                try container.decode(Schema.Offset.self, forKey: .offset).asAffineTransform
            } else {
                Self.default.transform
            }

        let value = try VC.Element.Properties(
            decorator: container.decodeIfPresent(Schema.Decorator.self, forKey: .decorator),
            padding: container.decodeIfPresent(Schema.EdgeInsets.self, forKey: .padding) ?? Self.default.padding,
            transform: transform,
            opacity: opacity,
            background: nil,
            overlay: nil,
            onAppear: onAppear,
            focusId: container.decodeIfPresent(String.self, forKey: .focusId),
            interactionEnabled: container.decodeIfPresent(Schema.Variable.self, forKey: .interactionEnabled)
        )

        let overlay = try container.decodeIfPresent([Schema.AlignedElement].self, forKey: .overlay, configuration: configuration)
        let background = try container.decodeIfPresent([Schema.AlignedElement].self, forKey: .overlay, configuration: configuration)

        try self.init(
            legacyElementId: container.decodeIfPresent(String.self, forKey: .legacyElementId),
            background: background.isEmpty ? nil : background,
            overlay: overlay.isEmpty ? nil : overlay,
            value: value.isEmpty ? nil : value
        )
    }
}

