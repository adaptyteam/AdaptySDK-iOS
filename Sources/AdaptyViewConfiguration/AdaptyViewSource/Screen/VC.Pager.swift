//
//  VC.Pager.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension AdaptyViewSource {
    struct Pager: Sendable, Hashable {
        let pageWidth: AdaptyViewConfiguration.Pager.Length
        let pageHeight: AdaptyViewConfiguration.Pager.Length
        let pagePadding: AdaptyViewConfiguration.EdgeInsets
        let spacing: Double
        let content: [AdaptyViewSource.Element]
        let pageControl: AdaptyViewSource.Pager.PageControl?
        let animation: AdaptyViewConfiguration.Pager.Animation?
        let interactionBehavior: AdaptyViewConfiguration.Pager.InteractionBehavior
    }
}

extension AdaptyViewSource.Pager {
    struct PageControl: Sendable, Hashable {
        let layout: AdaptyViewConfiguration.Pager.PageControl.Layout
        let verticalAlignment: AdaptyViewConfiguration.VerticalAlignment
        let padding: AdaptyViewConfiguration.EdgeInsets
        let dotSize: Double
        let spacing: Double
        let colorAssetId: String?
        let selectedColorAssetId: String?
    }
}

extension AdaptyViewSource.Localizer {
    func pager(_ from: AdaptyViewSource.Pager) throws -> AdaptyViewConfiguration.Pager {
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

    private func pageControl(_ from: AdaptyViewSource.Pager.PageControl) throws -> AdaptyViewConfiguration.Pager.PageControl {
        .init(
            layout: from.layout,
            verticalAlignment: from.verticalAlignment,
            padding: from.padding,
            dotSize: from.dotSize,
            spacing: from.spacing,
            color: from.colorAssetId.flatMap { try? color($0) } ?? AdaptyViewConfiguration.Pager.PageControl.default.color,
            selectedColor: from.selectedColorAssetId.flatMap { try? color($0) } ?? AdaptyViewConfiguration.Pager.PageControl.default.selectedColor
        )
    }
}

extension AdaptyViewSource.Pager: Decodable {
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
        let def = AdaptyViewConfiguration.Pager.default
        pageWidth = try container.decodeIfPresent(AdaptyViewConfiguration.Pager.Length.self, forKey: .pageWidth) ?? def.pageWidth
        pageHeight = try container.decodeIfPresent(AdaptyViewConfiguration.Pager.Length.self, forKey: .pageHeight) ?? def.pageHeight
        pagePadding = try container.decodeIfPresent(AdaptyViewConfiguration.EdgeInsets.self, forKey: .pagePadding) ?? def.pagePadding
        spacing = try container.decodeIfPresent(Double.self, forKey: .spacing) ?? def.spacing
        content = try container.decode([AdaptyViewSource.Element].self, forKey: .content)
        pageControl = try container.decodeIfPresent(AdaptyViewSource.Pager.PageControl.self, forKey: .pageControl)
        animation = try container.decodeIfPresent(AdaptyViewConfiguration.Pager.Animation.self, forKey: .animation)
        interactionBehavior = try container.decodeIfPresent(AdaptyViewConfiguration.Pager.InteractionBehavior.self, forKey: .interactionBehavior) ?? def.interactionBehavior
    }
}

extension AdaptyViewSource.Pager.PageControl: Decodable {
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
        let def = AdaptyViewConfiguration.Pager.PageControl.default
        layout = try container.decodeIfPresent(AdaptyViewConfiguration.Pager.PageControl.Layout.self, forKey: .layout) ?? def.layout
        verticalAlignment = try container.decodeIfPresent(AdaptyViewConfiguration.VerticalAlignment.self, forKey: .verticalAlignment) ?? def.verticalAlignment
        padding = try container.decodeIfPresent(AdaptyViewConfiguration.EdgeInsets.self, forKey: .padding) ?? def.padding
        dotSize = try container.decodeIfPresent(Double.self, forKey: .dotSize) ?? def.dotSize
        spacing = try container.decodeIfPresent(Double.self, forKey: .spacing) ?? def.spacing
        colorAssetId = try container.decodeIfPresent(String.self, forKey: .colorAssetId)
        selectedColorAssetId = try container.decodeIfPresent(String.self, forKey: .selectedColorAssetId)
    }
}

extension AdaptyViewConfiguration.Pager.Length: Decodable {
    enum CodingKeys: String, CodingKey {
        case parent
    }

    package init(from decoder: Decoder) throws {
        if let value = try? decoder.singleValueContainer().decode(AdaptyViewConfiguration.Unit.self) {
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
