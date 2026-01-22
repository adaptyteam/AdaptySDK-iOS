//
//  VC.AssetReference.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 08.01.2026.
//

import Foundation

package extension VC {
    enum AssetReference: Sendable, Hashable {
        case assetId(AssetIdentifier)
        case color(Color)
        case variable(Variable)
    }
}
