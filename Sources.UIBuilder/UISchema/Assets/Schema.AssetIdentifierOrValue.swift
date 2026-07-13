//
//  Schema.AssetIdentifierOrValue.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 08.02.2026.
//

import Foundation

extension Schema {
    typealias AssetIdentifierOrValue = VC.AssetIdentifierOrValue
}

extension Schema.AssetIdentifierOrValue: Decodable {
    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)

        self =
            if let color = Schema.Color(rawValue: value) {
                .color(color)
            } else {
                .assetId(value)
            }
    }
}
