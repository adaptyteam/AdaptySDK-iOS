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
    static let `default` = Self(
        pageWidth: .default,
        pageHeight: .default,
        pagePadding: .zero,
        spacing: 0,
        content: [],
        pageControl: nil,
        animation: nil,
        interactionBehavior: .default
    )
}

extension Schema.Localizer {
    func planPager(
        _ value: Schema.Pager,
        _ properties: Schema.Element.Properties?,
        in workStack: inout [WorkItem]
    ) throws {
        workStack.append(.buildPager(value, properties))
        for item in value.content.reversed() {
            workStack.append(.planElement(item))
        }
    }

    func buildPager(
        _ from: Schema.Pager,
        _ properties: Schema.Element.Properties?,
        in resultStack: inout [VC.Element]
    ) {
        let count = from.content.count
        var elements = [VC.Element]()
        elements.reserveCapacity(count)
        for _ in 0 ..< count {
            elements.append(resultStack.removeLast())
        }
        elements.reverse()
        resultStack.append(.pager(
            .init(
                pageWidth: from.pageWidth,
                pageHeight: from.pageHeight,
                pagePadding: from.pagePadding,
                spacing: from.spacing,
                content: elements,
                pageControl: from.pageControl,
                animation: from.animation,
                interactionBehavior: from.interactionBehavior
            ),
            properties?.value
        ))
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
