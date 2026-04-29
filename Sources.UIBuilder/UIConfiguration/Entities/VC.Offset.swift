//
//  VC.Offset.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

extension VC {
    struct Offset: Sendable, Equatable {
        let x: Unit
        let y: Unit
    }
}

extension VC.Offset {
    @inlinable
    var isZero: Bool {
        x.isZero && y.isZero
    }
}

