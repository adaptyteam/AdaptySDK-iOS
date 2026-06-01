//
//  Schema.AlignedElement.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 12.03.2026.
//

import Foundation

extension Schema {
    struct AlignedElement: Sendable {
        let horizontalAlignment: Schema.HorizontalAlignment
        let verticalAlignment: Schema.VerticalAlignment
        let content: Schema.Element
    }
}

extension Schema.AlignedElement {
    static let `default` = (
        horizontalAlignment: VC.HorizontalAlignment.center,
        verticalAlignment: VC.VerticalAlignment.center
    )
}

extension Schema.ConfigurationBuilder {
    @inlinable
    func convertAlignedElements(
        _ items: [Schema.AlignedElement],
        _ indices: [VC.ElementIndex]
    ) -> [VC.AlignedElement] {
        var overlays = [VC.AlignedElement]()
        overlays.reserveCapacity(indices.count)
        for (i, item) in items.enumerated() {
            overlays.append(.init(
                horizontalAlignment: item.horizontalAlignment,
                verticalAlignment: item.verticalAlignment,
                content: indices[i]
            ))
        }
        return overlays
    }
}

extension Schema.AlignedElement: DecodableWithConfiguration {
    enum CodingKeys: String, CodingKey {
        case horizontalAlignment = "h_align"
        case verticalAlignment = "v_align"
        case content
    }

    init(from decoder: Decoder, configuration: Schema.DecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            horizontalAlignment: container.decodeIfPresent(Schema.HorizontalAlignment.self, forKey: .horizontalAlignment) ?? Self.default.horizontalAlignment,
            verticalAlignment: container.decodeIfPresent(Schema.VerticalAlignment.self, forKey: .verticalAlignment) ?? Self.default.verticalAlignment,
            content: container.decode(Schema.Element.self, forKey: .content, configuration: configuration)
        )
    }
}
