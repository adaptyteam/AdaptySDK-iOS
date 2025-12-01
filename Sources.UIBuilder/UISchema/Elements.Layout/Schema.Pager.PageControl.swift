//
//  Schema.Pager.PageControl.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.11.2025.
//

import Foundation

extension Schema.Pager {
    struct PageControl: Sendable, Hashable {
        let layout: Layout
        let verticalAlignment: Schema.VerticalAlignment
        let padding: Schema.EdgeInsets
        let dotSize: Double
        let spacing: Double
        let colorAssetId: String?
        let selectedColorAssetId: String?
    }
}

extension Schema.Pager.PageControl {
    static let `default` = VC.Pager.PageControl.default
}

extension Schema.Localizer {
    func pageControl(_ from: Schema.Pager.PageControl) -> VC.Pager.PageControl {
        .init(
            layout: from.layout,
            verticalAlignment: from.verticalAlignment,
            padding: from.padding,
            dotSize: from.dotSize,
            spacing: from.spacing,
            color: from.colorAssetId.flatMap { try? color($0) } ?? VC.Pager.PageControl.default.color,
            selectedColor: from.selectedColorAssetId.flatMap { try? color($0) } ?? VC.Pager.PageControl.default.selectedColor
        )
    }
}

extension Schema.Pager.PageControl: Decodable {
    enum CodingKeys: String, CodingKey {
        case layout
        case verticalAlignment = "v_align"
        case padding
        case dotSize = "dot_size"
        case spacing
        case colorAssetId = "color"
        case selectedColorAssetId = "selected_color"
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            layout: container.decodeIfPresent(Layout.self, forKey: .layout)
                ?? Self.default.layout,
            verticalAlignment: container.decodeIfPresent(Schema.VerticalAlignment.self, forKey: .verticalAlignment)
                ?? Self.default.verticalAlignment,
            padding: container.decodeIfPresent(Schema.EdgeInsets.self, forKey: .padding)
                ?? Self.default.padding,
            dotSize: container.decodeIfPresent(Double.self, forKey: .dotSize)
                ?? Self.default.dotSize,
            spacing: container.decodeIfPresent(Double.self, forKey: .spacing)
                ?? Self.default.spacing,
            colorAssetId: container.decodeIfPresent(String.self, forKey: .colorAssetId),

            selectedColorAssetId: container.decodeIfPresent(String.self, forKey: .selectedColorAssetId)
        )
    }
}
