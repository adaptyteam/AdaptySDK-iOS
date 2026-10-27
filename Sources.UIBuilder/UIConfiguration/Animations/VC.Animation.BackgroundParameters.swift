//
//  VC.Animation.BackgroundParameters.swift
//  AdaptyUIBulder
//
//  Created by Aleksei Valiano on 27.10.2026.
//

import Foundation

extension VC.Animation {
    struct BackgroundParameters: Sendable {
        let color: Range<VC.AssetReference>
        let targetId: Int
    }
}
