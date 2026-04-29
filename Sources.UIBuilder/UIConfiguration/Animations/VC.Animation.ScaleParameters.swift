//
//  VC.Animation.ScaleParameters.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 20.03.2025
//

import Foundation

extension VC.Animation {
    struct ScaleParameters: Sendable, Equatable {
        let scale: Range<VC.Point>
        let anchor: VC.Point
    }
}
