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
        case text(AdaptyUI.ViewConfiguration.TextBlock, Properties?)
        case image(AdaptyUI.ViewConfiguration.Image, Properties?)
        indirect case button(AdaptyUI.ViewConfiguration.Button, Properties?)
        case unknown(String, Properties?)
    }
}

extension AdaptyUI.ViewConfiguration.Element {
    struct Properties {
        let decorastor: AdaptyUI.ViewConfiguration.Decorator?
        let frsme: AdaptyUI.Frame?
        let padding: AdaptyUI.EdgeInsets
        let offset: AdaptyUI.Offset

        let visibility: Bool
        let transitionIn: [AdaptyUI.Transition]

        var isZero: Bool {
            decorastor == nil
                && frsme == nil
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
            decorastor: from.decorastor.map(decorator),
            frsme: from.frsme,
            padding: from.padding,
            offset: from.offset,
            visibility: from.visibility,
            transitionIn: from.transitionIn
        )
    }
}
