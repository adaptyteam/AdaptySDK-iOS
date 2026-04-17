//
//  VC.LinearProgress.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 16.04.2026.
//

import Foundation

extension VC {
    struct LinearProgress: Sendable, Hashable {
        let orientation: Orientation // align
        let cornerRadius: CornerRadius // corner_radius
        let asset: AssetReference // asset_id
        let imageAspect: AspectRatio // image_aspect
        let clip: Bool // clip
        let value: Variable
        let transition: Transition
        let actions: [Action]
    }
}

extension VC.LinearProgress {
    enum Orientation: Sendable, Hashable {
        case horizontal(VC.HorizontalAlignment)
        case vertical(VC.VerticalAlignment)
    }
}

