//
//  Element.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    enum Element {
        case space(Int)
        indirect case stack(AdaptyUI.ViewConfiguration.Stack, Properties?)
        case text(AdaptyUI.ViewConfiguration.Text, Properties?)
        case image(AdaptyUI.ViewConfiguration.Image, Properties?)
        indirect case button(AdaptyUI.ViewConfiguration.Button, Properties?)
        case unknown(String, Properties?)
    }
}

extension AdaptyUI.ViewConfiguration.Element {
    struct Properties {
        let decorator: AdaptyUI.ViewConfiguration.Decorator?
        let frame: AdaptyUI.Frame?
        let padding: AdaptyUI.EdgeInsets
        let offset: AdaptyUI.Offset

        let visibility: Bool
        let transitionIn: [AdaptyUI.Transition]

        var isZero: Bool {
            decorator == nil
                && frame == nil
                && padding.isZero
                && offset.isZero
                && visibility
                && transitionIn.isEmpty
        }
    }
}

extension AdaptyUI.ViewConfiguration.Localizer {
    func element(_ from: AdaptyUI.ViewConfiguration.Element) -> AdaptyUI.Element {
        switch from {
        case let .space(value):
            .space(value)
        case let .stack(value, properties):
            .stack(stack(value), properties.flatMap(elementProperties))
        case let .text(value, properties):
            .text(richText(value), properties.flatMap(elementProperties))
        case let .image(value, properties):
            .image(image(value), properties.flatMap(elementProperties))
        case let .button(value, properties):
            .button(button(value), properties.flatMap(elementProperties))
        case let .unknown(value, properties):
            .unknown(value, properties.flatMap(elementProperties))
        }
    }

    private func elementProperties(_ from: AdaptyUI.ViewConfiguration.Element.Properties) -> AdaptyUI.Element.Properties? {
        guard !from.isZero else { return nil }
        return .init(
            decorator: from.decorator.map(decorator),
            frame: from.frame,
            padding: from.padding,
            offset: from.offset,
            visibility: from.visibility,
            transitionIn: from.transitionIn
        )
    }
}

extension AdaptyUI.ViewConfiguration.Element: Decodable {
    enum CodingKeys: String, CodingKey {
        case type
        case count
    }

    enum ContentType: String, Codable {
        case text
        case image
        case button
        case space
        case vStack = "v_stack"
        case hStack = "h_stack"
        case zStack = "z_stack"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        guard let contentType = ContentType(rawValue: type) else {
            self = .unknown(type, propertyOrNil())
            return
        }

        switch contentType {
        case .space:
            self = try .space(container.decodeIfPresent(Int.self, forKey: .count) ?? 1)
        case .vStack, .hStack, .zStack:
            self = try .stack(AdaptyUI.ViewConfiguration.Stack(from: decoder), propertyOrNil())
        case .button:
            self = try .button(AdaptyUI.ViewConfiguration.Button(from: decoder), propertyOrNil())
        case .text:
            self = try .text(AdaptyUI.ViewConfiguration.Text(from: decoder), propertyOrNil())
        case .image:
            self = try .image(AdaptyUI.ViewConfiguration.Image(from: decoder), propertyOrNil())
        }

        func propertyOrNil() -> Properties? {
            guard let value = try? Properties(from: decoder) else { return nil }
            return value.isZero ? nil : value
        }
    }
}

extension AdaptyUI.ViewConfiguration.Element.Properties: Decodable {
    enum CodingKeys: String, CodingKey {
        case decorator
        case frame
        case padding
        case offset
        case visibility
        case transitionIn = "transition_in"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let transitionIn: [AdaptyUI.Transition] =
            if let array = try? container.decodeIfPresent([AdaptyUI.Transition].self, forKey: .transitionIn) {
                array
            } else if let union = try? container.decodeIfPresent(AdaptyUI.TransitionUnion.self, forKey: .transitionIn) {
                union.items
            } else if let transition = try container.decodeIfPresent(AdaptyUI.Transition.self, forKey: .transitionIn) {
                [transition]
            } else {
                []
            }
        try self.init(
            decorator: container.decodeIfPresent(AdaptyUI.ViewConfiguration.Decorator.self, forKey: .decorator),
            frame: container.decodeIfPresent(AdaptyUI.Frame.self, forKey: .frame),
            padding: container.decodeIfPresent(AdaptyUI.EdgeInsets.self, forKey: .padding) ?? AdaptyUI.EdgeInsets.zero,
            offset: container.decodeIfPresent(AdaptyUI.Offset.self, forKey: .offset) ?? AdaptyUI.Offset.zero,
            visibility: container.decodeIfPresent(Bool.self, forKey: .visibility) ?? true,
            transitionIn: transitionIn
        )
    }
}
