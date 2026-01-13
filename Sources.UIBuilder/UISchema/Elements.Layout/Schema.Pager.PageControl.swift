//
//  Schema.Pager.PageControl.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.11.2025.
//

import Foundation

extension Schema.Pager {
    typealias PageControl = VC.Pager.PageControl
}

extension Schema.Pager.PageControl {
    static let `default` = VC.Pager.PageControl(
        layout: .stacked,
        verticalAlignment: .bottom,
        padding: .init(same: .point(6)),
        dotSize: 6,
        spacing: 6,
        color: nil,
        selectedColor: nil
    )
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
            color: container.decodeIfPresent(Schema.AssetReference.self, forKey: .colorAssetId),

            selectedColor: container.decodeIfPresent(Schema.AssetReference.self, forKey: .selectedColorAssetId)
        )
    }
}
