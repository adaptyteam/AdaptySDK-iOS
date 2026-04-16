//
//  Schema.Pager.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    struct Pager: Sendable {
        let pageWidth: Length
        let pageHeight: Length
        let pagePadding: EdgeInsets
        let spacing: Double
        let content: [Element]
        let pageControl: PageControl?
        let animation: Animation?
        let interactionBehavior: InteractionBehavior
        let pageIndex: Schema.Variable?
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
        interactionBehavior: .default,
        pageIndex: nil
    )
}

extension Schema.Pager: Schema.CompositeElement {
    @inlinable
    func planTasks(in taskStack: inout Schema.ConfigurationBuilder.TasksStack) {
        for item in content.reversed() {
            taskStack.append(.planElement(item))
        }
    }

    @inlinable
    func buildElement(
        _: Schema.ConfigurationBuilder,
        _ properties: VC.Element.Properties?,
        _ resultStack: inout Schema.ConfigurationBuilder.ResultStack
    ) throws(Schema.Error) -> VC.Element {
        try .pager(
            .init(
                pageWidth: pageWidth,
                pageHeight: pageHeight,
                pagePadding: pagePadding,
                spacing: spacing,
                content: resultStack.popLastElements(content.count),
                pageControl: pageControl,
                animation: animation,
                interactionBehavior: interactionBehavior,
                pageIndex: pageIndex
            ),
            properties
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
        case pageIndex = "page_index"
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
                ?? Self.default.interactionBehavior,
            pageIndex: container.decodeIfPresent(Schema.Variable.self, forKey: .pageIndex)
        )
    }
}
