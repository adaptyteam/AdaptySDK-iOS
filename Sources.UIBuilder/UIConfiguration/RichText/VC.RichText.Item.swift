//
//  VC.RichText.Item.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 01.12.2025.
//

import Foundation

extension VC.RichText {
    enum Item: Sendable, Hashable {
        case text(String, Attributes?, VC.Action?)
        case tag(String, Attributes?, VC.AnyConverter?, VC.Action?)
        case image(VC.AssetReference, Attributes?)
        case unknown
    }
}

extension VC.RichText.Item {
    func apply(defaultAttributes: VC.RichText.Attributes?) -> Self {
        guard let defaultAttributes, !defaultAttributes.isEmpty else { return self }

        return switch self {
        case let .text(value, attributes, action):
            .text(value, attributes?.apply(default: defaultAttributes) ?? defaultAttributes, action)
        case let .tag(value, attributes, converter, action):
            .tag(value, attributes?.apply(default: defaultAttributes) ?? defaultAttributes, converter, action)
        case let .image(assetId, attributes):
            .image(assetId, attributes?.apply(default: defaultAttributes) ?? defaultAttributes)
        default:
            .unknown
        }
    }
}

extension [VC.RichText.Item] {
    func apply(defaultAttributes: VC.RichText.Attributes?) -> Self {
        guard let defaultAttributes, !defaultAttributes.isEmpty else { return self }
        return self.map { $0.apply(defaultAttributes: defaultAttributes) }
    }
}

