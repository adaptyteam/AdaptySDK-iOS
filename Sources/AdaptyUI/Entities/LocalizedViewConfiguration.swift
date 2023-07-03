//
//  LocalizedViewConfiguration.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI {
    public struct LocalizedViewConfiguration {
        public let id: String
        public let templateId: String
        public let locale: String
        public let styles: [String: LocalizedViewStyle]

        public let isHard: Bool
        public let mainImageRelativeHeight: Double?


        let version: Int64
    }

    public struct LocalizedViewStyle {
        public let featureBlock: AdaptyUI.FeaturesBlock
        public let productBlock: AdaptyUI.ProductsBlock
        public let footerBlock: AdaptyUI.FooterBlock?
        public let items: [String: AdaptyUI.LocalizedViewItem]
    }

    public enum LocalizedViewItem {
        case filling(AdaptyUI.Filling)
        case shape(AdaptyUI.Shape)
        case button(AdaptyUI.Button)
        case text(AdaptyUI.Text)
        case textRows(AdaptyUI.TextRows)
        case unknown(String?)

        public var asFilling: AdaptyUI.Filling? {
            switch self {
            case let .filling(value): return value
            default: return nil
            }
        }

        public var asColor: AdaptyUI.Color? { asFilling?.asColor }
        public var asColorLinearGradient: AdaptyUI.ColorLinearGradient? { asFilling?.asColorLinearGradient }
        public var asImage: AdaptyUI.Image? { asFilling?.asImage }

        public var asShape: AdaptyUI.Shape? {
            switch self {
            case let .shape(value): return value
            default: return nil
            }
        }

        public var asButton: AdaptyUI.Button? {
            switch self {
            case let .button(value): return value
            default: return nil
            }
        }

        public var asText: AdaptyUI.Text? {
            switch self {
            case let .text(value): return value
            default: return nil
            }
        }

        public var asTextRows: AdaptyUI.TextRows? {
            switch self {
            case let .textRows(value): return value
            default: return nil
            }
        }
    }
}

extension Dictionary where Key == String, Value == AdaptyUI.LocalizedViewItem {
    public func getFilling(_ key: Key) -> AdaptyUI.Filling? { self[key]?.asFilling }
    public func getColor(_ key: Key) -> AdaptyUI.Color? { self[key]?.asFilling?.asColor }
    public func getColorLinearGradient(_ key: Key) -> AdaptyUI.ColorLinearGradient? { self[key]?.asFilling?.asColorLinearGradient }
    public func getShape(_ key: Key) -> AdaptyUI.Shape? { self[key]?.asShape }
    public func getButton(_ key: Key) -> AdaptyUI.Button? { self[key]?.asButton }
    public func getImage(_ key: Key) -> AdaptyUI.Image? { self[key]?.asFilling?.asImage }
    public func getText(_ key: Key) -> AdaptyUI.Text? { self[key]?.asText }
    public func getTextRows(_ key: Key) -> AdaptyUI.TextRows? { self[key]?.asTextRows }
}

extension AdaptyUI.LocalizedViewConfiguration: CustomStringConvertible {
    public var description: String {
        "(id: \(id), templateId: \(templateId), locale: \(locale), version: \(version), isHard: \(isHard))"
    }
}
