//
//  Schema.Pager.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    struct Pager: Sendable {
        let pageWidth: AdaptyUIConfiguration.Pager.Length
        let pageHeight: AdaptyUIConfiguration.Pager.Length
        let pagePadding: AdaptyUIConfiguration.EdgeInsets
        let spacing: Double
        let content: [Schema.Element]
        let pageControl: Schema.Pager.PageControl?
        let animation: AdaptyUIConfiguration.Pager.Animation?
        let interactionBehavior: AdaptyUIConfiguration.Pager.InteractionBehavior
    }
}

extension Schema.Pager {
    struct PageControl: Sendable, Hashable {
        let layout: AdaptyUIConfiguration.Pager.PageControl.Layout
        let verticalAlignment: AdaptyUIConfiguration.VerticalAlignment
        let padding: AdaptyUIConfiguration.EdgeInsets
        let dotSize: Double
        let spacing: Double
        let colorAssetId: String?
        let selectedColorAssetId: String?
    }
}

extension Schema.Localizer {
    func pager(_ from: Schema.Pager) throws -> AdaptyUIConfiguration.Pager {
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

    private func pageControl(_ from: Schema.Pager.PageControl) -> AdaptyUIConfiguration.Pager.PageControl {
        .init(
            layout: from.layout,
            verticalAlignment: from.verticalAlignment,
            padding: from.padding,
            dotSize: from.dotSize,
            spacing: from.spacing,
            color: from.colorAssetId.flatMap { try? color($0) } ?? AdaptyUIConfiguration.Pager.PageControl.default.color,
            selectedColor: from.selectedColorAssetId.flatMap { try? color($0) } ?? AdaptyUIConfiguration.Pager.PageControl.default.selectedColor
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
        let def = AdaptyUIConfiguration.Pager.default
        pageWidth = try container.decodeIfPresent(AdaptyUIConfiguration.Pager.Length.self, forKey: .pageWidth) ?? def.pageWidth
        pageHeight = try container.decodeIfPresent(AdaptyUIConfiguration.Pager.Length.self, forKey: .pageHeight) ?? def.pageHeight
        pagePadding = try container.decodeIfPresent(AdaptyUIConfiguration.EdgeInsets.self, forKey: .pagePadding) ?? def.pagePadding
        spacing = try container.decodeIfPresent(Double.self, forKey: .spacing) ?? def.spacing
        content = try container.decode([Schema.Element].self, forKey: .content)
        pageControl = try container.decodeIfPresent(Schema.Pager.PageControl.self, forKey: .pageControl)
        animation = try container.decodeIfPresent(AdaptyUIConfiguration.Pager.Animation.self, forKey: .animation)
        interactionBehavior = try container.decodeIfPresent(AdaptyUIConfiguration.Pager.InteractionBehavior.self, forKey: .interactionBehavior) ?? def.interactionBehavior
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
        let def = AdaptyUIConfiguration.Pager.PageControl.default
        layout = try container.decodeIfPresent(AdaptyUIConfiguration.Pager.PageControl.Layout.self, forKey: .layout) ?? def.layout
        verticalAlignment = try container.decodeIfPresent(AdaptyUIConfiguration.VerticalAlignment.self, forKey: .verticalAlignment) ?? def.verticalAlignment
        padding = try container.decodeIfPresent(AdaptyUIConfiguration.EdgeInsets.self, forKey: .padding) ?? def.padding
        dotSize = try container.decodeIfPresent(Double.self, forKey: .dotSize) ?? def.dotSize
        spacing = try container.decodeIfPresent(Double.self, forKey: .spacing) ?? def.spacing
        colorAssetId = try container.decodeIfPresent(String.self, forKey: .colorAssetId)
        selectedColorAssetId = try container.decodeIfPresent(String.self, forKey: .selectedColorAssetId)
    }
}

extension AdaptyUIConfiguration.Pager.Length: Decodable {
    enum CodingKeys: String, CodingKey {
        case parent
    }

    package init(from decoder: Decoder) throws {
        if let value = try? decoder.singleValueContainer().decode(AdaptyUIConfiguration.Unit.self) {
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
