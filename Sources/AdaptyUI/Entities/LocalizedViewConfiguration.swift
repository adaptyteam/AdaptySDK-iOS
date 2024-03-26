//
//  LocalizedViewConfiguration.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
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
        public let featureBlock: AdaptyUI.OldFeaturesBlock?
        public let productBlock: AdaptyUI.OldProductsBlock
        public let footerBlock: AdaptyUI.OldFooterBlock?
        public let items: [String: AdaptyUI.LocalizedViewItem]
    }

    public enum LocalizedViewItem {
        case filling(AdaptyUI.Filling)
        case shape(AdaptyUI.OldShape)
        case button(AdaptyUI.OldButton)
        case text(AdaptyUI.RichText)
        case object(AdaptyUI.OldCustomObject)
        case unknown(String?)

        public var asFilling: AdaptyUI.Filling? {
            switch self {
            case let .filling(value): value
            default: nil
            }
        }

        public var asColor: AdaptyUI.Color? { asFilling?.asColor }
        public var asColorGradient: AdaptyUI.ColorGradient? { asFilling?.asColorGradient }
        public var asImage: AdaptyUI.ImageData? { asFilling?.asImage }

        public var asShape: AdaptyUI.OldShape? {
            switch self {
            case let .shape(value): value
            default: nil
            }
        }

        public var asButton: AdaptyUI.OldButton? {
            switch self {
            case let .button(value): value
            default: nil
            }
        }

        public var asText: AdaptyUI.RichText? {
            switch self {
            case let .text(value): value
            default: nil
            }
        }

        public var asObject: AdaptyUI.OldCustomObject? {
            switch self {
            case let .object(value): value
            default: nil
            }
        }
    }
}

extension [String: AdaptyUI.LocalizedViewItem] {
    public func getFilling(_ key: Key) -> AdaptyUI.Filling? { self[key]?.asFilling }
    public func getColor(_ key: Key) -> AdaptyUI.Color? { self[key]?.asFilling?.asColor }
    public func getColorGradient(_ key: Key) -> AdaptyUI.ColorGradient? { self[key]?.asFilling?.asColorGradient }
    public func getShape(_ key: Key) -> AdaptyUI.OldShape? { self[key]?.asShape }
    public func getButton(_ key: Key) -> AdaptyUI.OldButton? { self[key]?.asButton }
    public func getImage(_ key: Key) -> AdaptyUI.ImageData? { self[key]?.asFilling?.asImage }
    public func getText(_ key: Key) -> AdaptyUI.RichText? { self[key]?.asText }
    public func getObject(_ key: Key) -> AdaptyUI.OldCustomObject? { self[key]?.asObject }
}

extension AdaptyUI.LocalizedViewConfiguration: CustomStringConvertible {
    public var description: String {
        "(id: \(id), templateId: \(templateId), locale: \(locale), version: \(version), isHard: \(isHard))"
    }
}
