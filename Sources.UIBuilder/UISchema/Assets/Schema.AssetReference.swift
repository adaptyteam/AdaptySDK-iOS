//
//  Schema.AssetReference.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 09.01.2026.
//

import Foundation

extension Schema {
    typealias AssetReference = VC.AssetReference
}

extension Schema.AssetReference: Codable {
    package init(from decoder: Decoder) throws {
        guard let container = try? decoder.singleValueContainer() else {
            self = try .variable(Schema.Variable(from: decoder))
            return
        }
        self = try .assetId(container.decode(String.self))
    }

    package func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .assetId(let value):
            try container.encode(value)
        case .variable(let variable):
            try container.encode(variable)
        }
    }
}
