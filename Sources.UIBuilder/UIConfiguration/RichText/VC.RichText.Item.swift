//
//  VC.RichText.Item.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 01.12.2025.
//

import Foundation

package extension VC.RichText {
    enum Item: Sendable, Hashable {
        case text(String, Attributes?)
        case tag(String, Attributes?)
        case image(VC.AssetReference, Attributes?)
        case unknown
    }
}

package extension VC.RichText.Item {
    func apply(defaultAttributes: VC.RichText.Attributes?) -> Self {
        guard let defaultAttributes, !defaultAttributes.isEmpty else { return self }

        return switch self {
        case let .text(value, attributes):
            .text(value, attributes.apply(default: defaultAttributes))
        case let .tag(value, attributes):
            .tag(value, attributes.apply(default: defaultAttributes))
        case let .image(assetId, attributes):
            .image(assetId, attributes.apply(default: defaultAttributes))
        default:
            .unknown
        }
    }
}
