//
//  VC.Scale.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.03.2026.
//

import Foundation

extension VC {
    struct Scale: Sendable, Equatable {
        let scale: VC.Point
        let anchor: VC.Point
    }
}

extension VC.Scale {
    @inlinable
    var isEmpty: Bool {
        scale.x == 1
        && scale.y == 1
    }
}

