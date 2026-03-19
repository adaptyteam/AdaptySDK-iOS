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
//        guard let from else { return }
//        if let background = from.background, background.isNotEmpty {
//            for overlay in background.reversed() {
//                taskStack.append(.planElement(overlay.content))
//            }
//        }
//        if let overlays = from.overlay, overlays.isNotEmpty {
//            for overlay in overlays.reversed() {
//                taskStack.append(.planElement(overlay.content))
//            }
//        }
    }

    @inlinable
    func buildElementProperties(
        _ from: Schema.Element.Properties?,
        _ resultStack: inout ResultStack
    ) throws(Schema.Error) -> VC.Element.Properties? {
        guard let from else { return nil }

        var background: [VC.Element.Overlay]? = nil
//            if let backgrounds = from.background, backgrounds.isNotEmpty {
//                try convertElementOverlays(
//                    backgrounds,
//                    resultStack.popLastElements(backgrounds.count)
//                )
//            } else {
//                nil
//            }
        var overlay: [VC.Element.Overlay]? = nil
//            if let overlays = from.overlay, overlays.isNotEmpty {
//                try convertElementOverlays(
//                    overlays,
//                    resultStack.popLastElements(overlays.count)
//                )
//            } else {
//                nil
//            }

        if background?.isEmpty ?? false { background = nil }
        if overlay?.isEmpty ?? false { overlay = nil }

        if let value = from.value, !value.isEmpty {
            return .init(
                decorator: value.decorator,
                padding: value.padding,
                offset: value.offset,
                opacity: value.opacity,
                background: background,
                overlay: overlay,
                onAppear: value.onAppear
            )
        }

        guard background == .none, overlay == .none else {
            return nil
        }

        return .init(
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
            background: nil,
            overlay: nil,
            onAppear: onAppear
        )

        let overlay = try container.decodeIfPresent([Schema.Element.Overlay].self, forKey: .overlay, configuration: configuration)
        let background = try container.decodeIfPresent([Schema.Element.Overlay].self, forKey: .overlay, configuration: configuration)

        try self.init(
            legacyElementId: container.decodeIfPresent(String.self, forKey: .legacyElementId),
            background: background.isEmpty ? nil : background,
            overlay: overlay.isEmpty ? nil : overlay,
            value: value.isEmpty ? nil : value
        )
    }
}

