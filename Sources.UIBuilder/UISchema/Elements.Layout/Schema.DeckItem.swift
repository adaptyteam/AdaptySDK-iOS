//
//  Schema.DeckItem.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 21.08.2026.
//

import Foundation

extension Schema {
    struct DeckItem: Sendable {
        let width: Length
        let height: Length
        let anchor: Point
        let position: Point
        let mirrorInRTL: Bool
        let content: Element
        @available(*, deprecated, message: "Use anchor, position and mirrorInRTL instead.")
        let deprecatedHorizontalAlignment: HorizontalAlignment
        @available(*, deprecated, message: "Use anchor and position instead.")
        let deprecatedVerticalAlignment: VerticalAlignment
    }
}

extension Schema.DeckItem {
    static let `default` = (
        horizontalAlignment: VC.HorizontalAlignment.center,
        verticalAlignment: VC.VerticalAlignment.center
    )
}

extension Schema.ConfigurationBuilder {
    @inlinable
    func convertDeckItems(
        _ items: [Schema.DeckItem],
        _ elements: [VC.ElementIndex]
    ) -> [VC.DeckItem] {
        var deckItems = [VC.DeckItem]()
        deckItems.reserveCapacity(elements.count)
        for (index, item) in items.enumerated() {
            deckItems.append(.init(
                width: item.width,
                height: item.height,
                anchor: item.anchor,
                position: item.position,
                mirrorInRTL: item.mirrorInRTL,
                content: elements[index],
                deprecatedHorizontalAlignment: item.deprecatedHorizontalAlignment,
                deprecatedVerticalAlignment: item.deprecatedVerticalAlignment
            ))
        }
        return deckItems
    }
}

extension Schema.DeckItem: DecodableWithConfiguration {
    static let typeForDeckItem = "deck_item"

    enum CodingKeys: String, CodingKey {
        case type
        case width
        case height
        case anchor
        case position
        case rtlBehavior = "rtl"
        case horizontalAlignment = "h_align"
        case verticalAlignment = "v_align"
        case content
    }

    init(from decoder: Decoder, configuration: Schema.InternalDecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let type = try container.decode(String.self, forKey: .type)

        guard type == Self.typeForDeckItem else {
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Invalid DeckItem type: \(type)"
            )
        }

        let horizontalAlignment: Schema.HorizontalAlignment
        let verticalAlignment: Schema.VerticalAlignment
        let anchor: Schema.Point
        let position: Schema.Point
        let rtlBehavior: Schema.RTLBehavior

        if container.contains(.anchor) || container.contains(.position) {
            guard !container.contains(.horizontalAlignment), !container.contains(.verticalAlignment) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .anchor,
                    in: container,
                    debugDescription: "DeckItem must use either anchor and position or h_align and v_align"
                )
            }

            anchor = try container.decode(Schema.Point.self, forKey: .anchor)
            position = try container.decode(Schema.Point.self, forKey: .position)
            rtlBehavior = try container.decodeIfPresent(Schema.RTLBehavior.self, forKey: .rtlBehavior) ?? .default
            horizontalAlignment = .center
            verticalAlignment = .center
        } else {
            guard !container.contains(.rtlBehavior) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .rtlBehavior,
                    in: container,
                    debugDescription: "DeckItem rtl requires anchor and position"
                )
            }

            horizontalAlignment = try container.decodeIfPresent(Schema.HorizontalAlignment.self, forKey: .horizontalAlignment) ?? Self.default.horizontalAlignment
            verticalAlignment = try container.decodeIfPresent(Schema.VerticalAlignment.self, forKey: .verticalAlignment) ?? Self.default.verticalAlignment
            anchor = calculatePoint(horizontalAlignment, verticalAlignment)
            position = anchor
            rtlBehavior = calculateRTLBehavior(horizontalAlignment)
        }

        self.init(
            width: try container.decodeIfPresent(Length.self, forKey: .width) ?? .content,
            height: try container.decodeIfPresent(Length.self, forKey: .height) ?? .content,
            anchor: anchor,
            position: position,
            mirrorInRTL: rtlBehavior.mirrorInRTL,
            content: try container.decode(Schema.Element.self, forKey: .content, configuration: configuration),
            deprecatedHorizontalAlignment: horizontalAlignment,
            deprecatedVerticalAlignment: verticalAlignment
        )

        func calculateRTLBehavior(
            _ horizontalAlignment: Schema.HorizontalAlignment,
        ) -> Schema.RTLBehavior {
            switch horizontalAlignment {
            case .leading, .trailing: .init(mirrorInRTL: true)
            case .left, .right, .center, .justified: .init(mirrorInRTL: false)
            }
        }

        func calculatePoint(
            _ horizontalAlignment: Schema.HorizontalAlignment,
            _ verticalAlignment: Schema.VerticalAlignment
        ) -> Schema.Point {
            switch (horizontalAlignment, verticalAlignment) {
            case (.leading, .top), (.left, .top): .init(x: 0, y: 0)
            case (.leading, .center), (.left, .center): .init(x: 0, y: 0.5)
            case (.leading, .bottom), (.left, .bottom): .init(x: 0, y: 1)
            case (.center, .top), (.justified, .top): .init(x: 0.5, y: 0)
            case (.center, .center), (.justified, .center): .center
            case (.center, .bottom), (.justified, .bottom): .init(x: 0.5, y: 1)
            case (.trailing, .top), (.right, .top): .init(x: 1, y: 0)
            case (.trailing, .center), (.right, .center): .init(x: 1, y: 0.5)
            case (.trailing, .bottom), (.right, .bottom): .init(x: 1, y: 1)
            }
        }
    }
}
