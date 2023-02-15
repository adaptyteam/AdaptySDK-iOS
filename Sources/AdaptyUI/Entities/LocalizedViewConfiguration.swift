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
        public let termsUrl: String?
        public let privacyUrl: String?
        let version: Int64
    }

    public struct LocalizedViewStyle {
        public let common: [String: AdaptyUI.LocalizedViewItem]?
        public let custom: [String: AdaptyUI.LocalizedViewItem]?

        var isEmpty: Bool {
            (common?.isEmpty ?? true) && (custom?.isEmpty ?? true)
        }
    }

    public enum LocalizedViewItem {
        case color(AdaptyUI.Color)
        case image(AdaptyUI.Image)
        case text(AdaptyUI.Text)
        case textRows(AdaptyUI.TextRows)
        case unknown(String?)

        public var asColor: AdaptyUI.Color? {
            switch self {
            case let .color(value): return value
            default: return nil
            }
        }

        public var asImage: AdaptyUI.Image? {
            switch self {
            case let .image(value): return value
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
    public func getColor(_ key: Key) -> AdaptyUI.Color? { self[key]?.asColor }
    public func getImage(_ key: Key) -> AdaptyUI.Image? { self[key]?.asImage }
    public func getText(_ key: Key) -> AdaptyUI.Text? { self[key]?.asText }
    public func getTextRows(_ key: Key) -> AdaptyUI.TextRows? { self[key]?.asTextRows }
}

extension AdaptyUI.LocalizedViewConfiguration: CustomStringConvertible {
    public var description: String {
        "(id: \(id), templateId: \(templateId), locale: \(locale), version: \(version), isHard: \(isHard))"
    }
}
