//
//  Element.swift
//  AdaptySDK
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

extension AdaptyUI.ViewConfiguration.Element {
    func convert(_ assetById: (String?) -> AdaptyUI.ViewConfiguration.Asset?) -> AdaptyUI.Element {
        return switch self {
        case let .space(value):
            .space(value)
        case let .stack(value, properties):
            .stack(value.convert(assetById), convert(properties))
        case let .text(value, properties):
            .space(0)
        //  .text(value.convert(assetById, item: <#T##AdaptyUI.ViewConfiguration.Localization.Item#>),  convert(properties))
        case let .image(value, properties):
            .image(value.convert(assetById), convert(properties))
        case let .button(value, properties):
            .button(value.convert(assetById), convert(properties))
        case let .unknown(value, properties):
            .unknown(value, convert(properties))
        }

        func convert(_ value: AdaptyUI.ViewConfiguration.Element.Properties?) -> AdaptyUI.Element.Properties? {
            guard let value else { return nil }
            return value.convert(assetById)
        }
    }
}

extension AdaptyUI.ViewConfiguration.Element.Properties {
    func convert(_ assetById: (String?) -> AdaptyUI.ViewConfiguration.Asset?) -> AdaptyUI.Element.Properties? {
        guard !isZero else { return nil }
        return .init(
            decorastor: decorastor.map { $0.convert(assetById) },
            frsme: frsme,
            padding: padding,
            offset: offset,
            visibility: visibility,
            transitionIn: transitionIn
        )
    }
}
