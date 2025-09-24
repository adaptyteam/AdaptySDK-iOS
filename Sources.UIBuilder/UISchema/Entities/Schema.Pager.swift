//
//  Schema.Pager.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    struct Pager: Sendable {
        let pageWidth: VC.Pager.Length
        let pageHeight: VC.Pager.Length
        let pagePadding: VC.EdgeInsets
        let spacing: Double
        let content: [Schema.Element]
        let pageControl: Schema.Pager.PageControl?
        let animation: VC.Pager.Animation?
        let interactionBehavior: VC.Pager.InteractionBehavior
    }
}

extension Schema.Pager {
    struct PageControl: Sendable, Hashable {
        let layout: VC.Pager.PageControl.Layout
        let verticalAlignment: VC.VerticalAlignment
        let padding: VC.EdgeInsets
        let dotSize: Double
        let spacing: Double
        let colorAssetId: String?
        let selectedColorAssetId: String?
    }
}

extension Schema.Localizer {
    func pager(_ from: Schema.Pager) throws -> VC.Pager {
        try .init(
            pageWidth: from.pageWidth,
            pageHeight: from.pageHeight,
            pagePadding: from.pagePadding,
            spacing: from.spacing,
            content: from.content.map(element),
            pageControl: from.pageControl.map(pageControl),
            animation: from.animation,
            interactionBehavior: from.interactionBehavior
        )
    }

    private func pageControl(_ from: Schema.Pager.PageControl) -> VC.Pager.PageControl {
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

extension Schema.Pager: Decodable {
    enum CodingKeys: String, CodingKey {
        case pageWidth = "page_width"
        case pageHeight = "page_height"
        case pagePadding = "page_padding"
        case spacing
        case content
        case pageControl = "page_control"
        case animation
        case interactionBehavior = "interaction"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let def = VC.Pager.default
        pageWidth = try container.decodeIfPresent(VC.Pager.Length.self, forKey: .pageWidth) ?? def.pageWidth
        pageHeight = try container.decodeIfPresent(VC.Pager.Length.self, forKey: .pageHeight) ?? def.pageHeight
        pagePadding = try container.decodeIfPresent(VC.EdgeInsets.self, forKey: .pagePadding) ?? def.pagePadding
        spacing = try container.decodeIfPresent(Double.self, forKey: .spacing) ?? def.spacing
        content = try container.decode([Schema.Element].self, forKey: .content)
        pageControl = try container.decodeIfPresent(Schema.Pager.PageControl.self, forKey: .pageControl)
        animation = try container.decodeIfPresent(VC.Pager.Animation.self, forKey: .animation)
        interactionBehavior = try container.decodeIfPresent(VC.Pager.InteractionBehavior.self, forKey: .interactionBehavior) ?? def.interactionBehavior
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
        let def = VC.Pager.PageControl.default
        layout = try container.decodeIfPresent(VC.Pager.PageControl.Layout.self, forKey: .layout) ?? def.layout
        verticalAlignment = try container.decodeIfPresent(VC.VerticalAlignment.self, forKey: .verticalAlignment) ?? def.verticalAlignment
        padding = try container.decodeIfPresent(VC.EdgeInsets.self, forKey: .padding) ?? def.padding
        dotSize = try container.decodeIfPresent(Double.self, forKey: .dotSize) ?? def.dotSize
        spacing = try container.decodeIfPresent(Double.self, forKey: .spacing) ?? def.spacing
        colorAssetId = try container.decodeIfPresent(String.self, forKey: .colorAssetId)
        selectedColorAssetId = try container.decodeIfPresent(String.self, forKey: .selectedColorAssetId)
    }
}

extension VC.Pager.Length: Decodable {
    enum CodingKeys: String, CodingKey {
        case parent
    }

    package init(from decoder: Decoder) throws {
        if let value = try? decoder.singleValueContainer().decode(VC.Unit.self) {
            self = .fixed(value)
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let value = try container.decodeIfPresent(Double.self, forKey: .parent) {
                self = .parent(value)
            } else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "don't found parent"))
            }
        }
    }
}
