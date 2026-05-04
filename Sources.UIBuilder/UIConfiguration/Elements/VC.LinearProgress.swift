//
//  VC.LinearProgress.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 16.04.2026.
//

import Foundation

extension VC {
    struct LinearProgress: Sendable {
        let orientation: Orientation 
        let cornerRadius: CornerRadius
        let asset: AssetReference
        let imageAspect: AspectRatio
        let clip: Bool
        let value: Variable
        let transition: Transition
        let actions: [Action]
    }
}

extension VC.LinearProgress {
    enum Orientation: Sendable {
        case horizontal(VC.HorizontalAlignment)
        case vertical(VC.VerticalAlignment)
    }
}

