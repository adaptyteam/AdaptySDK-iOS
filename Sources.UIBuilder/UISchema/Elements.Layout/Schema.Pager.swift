//
//  Schema.Pager.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    struct Pager: Sendable, Hashable {
        let pageWidth: Length
        let pageHeight: Length
        let pagePadding: EdgeInsets
        let spacing: Double
        let content: [Element]
        let pageControl: PageControl?
        let animation: Animation?
        let interactionBehavior: InteractionBehavior
    }
}

extension Schema.Pager {
    static let `default` = VC.Pager.default
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
}

extension Schema.Pager: DecodableWithConfiguration {
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

    init(from decoder: Decoder, configuration: Schema.DecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            pageWidth: container.decodeIfPresent(Length.self, forKey: .pageWidth)
                ?? Self.default.pageWidth,
            pageHeight: container.decodeIfPresent(Length.self, forKey: .pageHeight)
                ?? Self.default.pageHeight,
            pagePadding: container.decodeIfPresent(Schema.EdgeInsets.self, forKey: .pagePadding)
                ?? Self.default.pagePadding,
            spacing: container.decodeIfPresent(Double.self, forKey: .spacing)
                ?? Self.default.spacing,
            content: container.decode([Schema.Element].self, forKey: .content, configuration: configuration),

            pageControl: container.decodeIfPresent(PageControl.self, forKey: .pageControl),

            animation: container.decodeIfPresent(Animation.self, forKey: .animation),

            interactionBehavior: container.decodeIfPresent(InteractionBehavior.self, forKey: .interactionBehavior)
                ?? Self.default.interactionBehavior
        )
    }
}
