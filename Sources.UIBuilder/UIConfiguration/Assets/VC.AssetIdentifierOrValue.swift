//
//  VC.AssetIdentifierOrValue.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 15.01.2026.
//

import Foundation

extension VC {
    enum AssetIdentifierOrValue: Sendable, Equatable {
        case assetId(AssetIdentifier)
        case color(Color)
    }
}
