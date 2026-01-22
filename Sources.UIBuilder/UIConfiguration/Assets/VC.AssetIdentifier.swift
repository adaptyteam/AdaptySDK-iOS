//
//  VC.AssetIdentifier.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 15.01.2026.
//

import Foundation

package extension VC {
    typealias AssetIdentifier = String

    enum AssetIdentifierOrValue: Sendable, Hashable {
        case assetId(AssetIdentifier)
        case color(Color)
    }
}
