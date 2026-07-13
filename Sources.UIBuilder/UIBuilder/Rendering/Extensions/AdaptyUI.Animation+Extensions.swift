//
//  AdaptyUI.Animation+Extensions.swift
//  AdaptyUIBuilder
//
//  Created by Alex Goncharov on 11/02/2026.
//

#if canImport(UIKit)

import Foundation

extension VC.Animation.Background {
    var initialBackground: VC.AssetReference {
        range.start
    }
}

extension [VC.Animation] {
    var totalDuration: TimeInterval {
        map(\.timeline)
            .map { $0.duration + $0.startDelay }
            .max() ?? 0.0
    }
}

#endif
