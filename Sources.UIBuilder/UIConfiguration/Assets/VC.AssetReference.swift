//
//  VC.AssetReference.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 08.01.2026.
//

import Foundation

extension VC {
    enum AssetReference: Sendable, Equatable {
        case assetId(AssetIdentifier)
        case color(Color)
        case variable(Variable)
    }
}

extension VC.AssetIdentifierOrValue {
    var asAssetReference: VC.AssetReference {
        switch self {
        case let .assetId(value):
            .assetId(value)
        case let .color(value):
            .color(value)
        }
    }
}

