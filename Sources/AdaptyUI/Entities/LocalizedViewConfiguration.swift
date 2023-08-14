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
        public let featureBlock: AdaptyUI.FeaturesBlock?
        public let productBlock: AdaptyUI.ProductsBlock
        public let footerBlock: AdaptyUI.FooterBlock?
        public let items: [String: AdaptyUI.LocalizedViewItem]
    }

    public enum LocalizedViewItem {
        case filling(AdaptyUI.Filling)
        case shape(AdaptyUI.Shape)
        case button(AdaptyUI.Button)
        case text(AdaptyUI.CompoundText)
        case object(AdaptyUI.CustomObject)
        case unknown(String?)

        public var asFilling: AdaptyUI.Filling? {
            switch self {
            case let .filling(value): return value
            default: return nil
            }
        }

        public var asColor: AdaptyUI.Color? { asFilling?.asColor }
        public var asColorGradient: AdaptyUI.ColorGradient? { asFilling?.asColorGradient }
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

        public var asText: AdaptyUI.CompoundText? {
            switch self {
            case let .text(value): return value
            default: return nil
            }
        }

        public var asObject: AdaptyUI.CustomObject? {
            switch self {
            case let .object(value): return value
            default: return nil
            }
        }
    }
}

extension Dictionary where Key == String, Value == AdaptyUI.LocalizedViewItem {
    public func getFilling(_ key: Key) -> AdaptyUI.Filling? { self[key]?.asFilling }
    public func getColor(_ key: Key) -> AdaptyUI.Color? { self[key]?.asFilling?.asColor }
    public func getColorGradient(_ key: Key) -> AdaptyUI.ColorGradient? { self[key]?.asFilling?.asColorGradient }
    public func getShape(_ key: Key) -> AdaptyUI.Shape? { self[key]?.asShape }
    public func getButton(_ key: Key) -> AdaptyUI.Button? { self[key]?.asButton }
    public func getImage(_ key: Key) -> AdaptyUI.Image? { self[key]?.asFilling?.asImage }
    public func getText(_ key: Key) -> AdaptyUI.CompoundText? { self[key]?.asText }
    public func getObject(_ key: Key) -> AdaptyUI.CustomObject? { self[key]?.asObject }
}

extension AdaptyUI.LocalizedViewConfiguration: CustomStringConvertible {
    public var description: String {
        "(id: \(id), templateId: \(templateId), locale: \(locale), version: \(version), isHard: \(isHard))"
    }
}
