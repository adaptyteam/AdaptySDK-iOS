//
//  VC.Pager.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct Pager {
        let pageWidth: AdaptyUI.Pager.Length
        let pageHeight: AdaptyUI.Pager.Length
        let pagePadding: AdaptyUI.EdgeInsets
        let spacing: Double
        let content: [AdaptyUI.ViewConfiguration.Element]
        let pageControl: AdaptyUI.ViewConfiguration.Pager.PageControl?
        let animation: AdaptyUI.Pager.Animation?
        let interactionBehaviour: AdaptyUI.Pager.InteractionBehaviour
    }
}

extension AdaptyUI.ViewConfiguration.Pager {
    struct PageControl {
        let layout: AdaptyUI.Pager.PageControl.Layout
        let verticalAlignment: AdaptyUI.VerticalAlignment
        let padding: AdaptyUI.EdgeInsets
        let dotSize: Double
        let spacing: Double
        let colorAssetId: String?
        let selectedColorAssetId: String?
    }
}

extension AdaptyUI.ViewConfiguration.Localizer {
    func pager(_ from: AdaptyUI.ViewConfiguration.Pager) throws -> AdaptyUI.Pager {
        try .init(
            pageWidth: from.pageWidth,
            pageHeight: from.pageHeight,
            pagePadding: from.pagePadding,
            spacing: from.spacing,
            content: from.content.map(element),
            pageControl: from.pageControl.map(pageControl),
            animation: from.animation,
            interactionBehaviour: from.interactionBehaviour
        )
    }

    private func pageControl(_ from: AdaptyUI.ViewConfiguration.Pager.PageControl) throws -> AdaptyUI.Pager.PageControl {
        .init(
            layout: from.layout,
            verticalAlignment: from.verticalAlignment,
            padding: from.padding,
            dotSize: from.dotSize,
            spacing: from.spacing,
            color: colorIfPresent(from.colorAssetId) ?? AdaptyUI.Pager.PageControl.default.color,
            selectedColor: colorIfPresent(from.selectedColorAssetId) ?? AdaptyUI.Pager.PageControl.default.selectedColor
        )
    }
}

extension AdaptyUI.ViewConfiguration.Pager: Decodable {
    enum CodingKeys: String, CodingKey {
        case pageWidth = "page_width"
        case pageHeight = "page_height"
        case pagePadding = "page_padding"
        case spacing
        case content
        case pageControl = "page_control"
        case animation
        case interactionBehaviour = "interaction_behaviour"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let def = AdaptyUI.Pager.default
        pageWidth = try container.decodeIfPresent(AdaptyUI.Pager.Length.self, forKey: .pageWidth) ?? def.pageWidth
        pageHeight = try container.decodeIfPresent(AdaptyUI.Pager.Length.self, forKey: .pageHeight) ?? def.pageHeight
        pagePadding = try container.decodeIfPresent(AdaptyUI.EdgeInsets.self, forKey: .pagePadding) ?? def.pagePadding
        spacing = try container.decodeIfPresent(Double.self, forKey: .spacing) ?? def.spacing
        content = try container.decode([AdaptyUI.ViewConfiguration.Element].self, forKey: .content)
        pageControl = try container.decodeIfPresent(AdaptyUI.ViewConfiguration.Pager.PageControl.self, forKey: .pageControl)
        animation = try container.decodeIfPresent(AdaptyUI.Pager.Animation.self, forKey: .animation)
        interactionBehaviour = try container.decodeIfPresent(AdaptyUI.Pager.InteractionBehaviour.self, forKey: .interactionBehaviour) ?? def.interactionBehaviour
    }
}

extension AdaptyUI.ViewConfiguration.Pager.PageControl: Decodable {
    enum CodingKeys: String, CodingKey {
        case layout
        case verticalAlignment = "v_align"
        case padding
        case dotSize = "dot_size"
        case spacing
        case colorAssetId
        case selectedColorAssetId = "selected_color"
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let def = AdaptyUI.Pager.PageControl.default
        layout = try container.decodeIfPresent(AdaptyUI.Pager.PageControl.Layout.self, forKey: .layout) ?? def.layout
        verticalAlignment = try container.decodeIfPresent(AdaptyUI.VerticalAlignment.self, forKey: .verticalAlignment) ?? def.verticalAlignment
        padding = try container.decodeIfPresent(AdaptyUI.EdgeInsets.self, forKey: .padding) ?? def.padding
        dotSize = try container.decodeIfPresent(Double.self, forKey: .dotSize) ?? def.dotSize
        spacing = try container.decodeIfPresent(Double.self, forKey: .spacing) ?? def.spacing
        colorAssetId = try container.decodeIfPresent(String.self, forKey: .colorAssetId)
        selectedColorAssetId = try container.decodeIfPresent(String.self, forKey: .selectedColorAssetId)
    }
}

extension AdaptyUI.Pager.Length: Decodable {
    enum CodingKeys: String, CodingKey {
        case parent
    }

    package init(from decoder: any Decoder) throws {
        if let value = try? decoder.singleValueContainer().decode(AdaptyUI.Unit.self) {
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
