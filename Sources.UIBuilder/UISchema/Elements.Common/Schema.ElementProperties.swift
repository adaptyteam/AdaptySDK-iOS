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
    @inlinable
    var isEmpty: Bool {
        legacyElementId == nil
            && (background?.isEmpty ?? true)
            && (overlay?.isEmpty ?? true)
            && (value?.isEmpty ?? true)
    }
}

extension Schema.ElementProperties {
    static let `default` = (
        padding: VC.EdgeInsets.zero,
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
                offset: value.offset,
                rotation: value.rotation,
                scale: value.scale,
                opacity: value.opacity,
                background: background ?? [],
                overlay: overlay ?? [],
                eventHandlers: value.eventHandlers,
                focusId: value.focusId,
                interactionEnabled: value.interactionEnabled
            )
        } else {
            .init(
                decorator: nil,
                padding: Schema.ElementProperties.default.padding,
                offset: nil,
                rotation: nil,
                scale: nil,
                opacity: Schema.ElementProperties.default.opacity,
                background: background,
                overlay: overlay,
                eventHandlers: [],
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
        case rotation
        case scale
        case visibility
        case opacity
        case legacyTransitionIn = "transition_in"
        case eventHandlers = "event_handlers"
        case legacyOnAppear = "on_appear"
        case overlay
        case background
        case focusId = "focus_id"
        case interactionEnabled = "ui_enabled"
    }

    init(from decoder: Decoder, configuration: Schema.DecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let eventHandlers: [Schema.EventHandler]
        if let array = try container.decodeIfPresent([Schema.EventHandler].self, forKey: .eventHandlers) {
            eventHandlers = array
        } else {
            let animations: [Schema.Animation] =

                if let array = try? container.decodeIfPresent([Schema.Animation].self, forKey: .legacyOnAppear) {
                    array
                } else if let value = try container.decodeIfPresent(Schema.Animation.self, forKey: .legacyTransitionIn) {
                    [value]
                } else {
                    []
                }

            eventHandlers =
                if animations.isEmpty {
                    []
                } else {
                    [.init(
                        triggers: [.init(
                            events: [.onWillAppiar],
                            filter: nil,
                            screenTransitions: nil
                        )],
                        animations: animations,
                        onAnimationsFinish: []
                    )]
                }
        }

        let opacity =
            if let value = try container.decodeIfPresent(Double.self, forKey: .opacity) {
                value
            } else if let value = try container.decodeIfPresent(Bool.self, forKey: .visibility) {
                value ? 1.0 : 0.0
            } else {
                Self.default.opacity
            }

        let offset = try container.decodeIfPresent(Schema.Offset.self, forKey: .offset)
        let rotation = try container.decodeIfPresent(Schema.Rotation.self, forKey: .rotation)
        let scale = try container.decodeIfPresent(Schema.Scale.self, forKey: .scale)

        let value = try VC.Element.Properties(
            decorator: container.decodeIfPresent(Schema.Decorator.self, forKey: .decorator),
            padding: container.decodeIfPresent(Schema.EdgeInsets.self, forKey: .padding) ?? Self.default.padding,
            offset: offset?.isZero ?? true ? nil : offset,
            rotation: rotation?.isZero ?? true ? nil : rotation,
            scale: scale?.isEmpty ?? true ? nil : scale,
            opacity: opacity,
            background: nil,
            overlay: nil,
            eventHandlers: eventHandlers.filter { !$0.isEmpty },
            focusId: container.decodeIfPresent(String.self, forKey: .focusId),
            interactionEnabled: container.decodeIfPresent(Schema.Variable.self, forKey: .interactionEnabled)
        )

        let overlay = try container.decodeIfExist([Schema.AlignedElement].self, forKey: .overlay, configuration: configuration)
        let background = try container.decodeIfExist([Schema.AlignedElement].self, forKey: .background, configuration: configuration)

        try self.init(
            legacyElementId: container.decodeIfPresent(String.self, forKey: .legacyElementId),
            background: background.isEmpty ? nil : background,
            overlay: overlay.isEmpty ? nil : overlay,
            value: value.isEmpty ? nil : value
        )
    }
}

