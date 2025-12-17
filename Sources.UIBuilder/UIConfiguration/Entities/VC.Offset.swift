//
//  VC.Offset.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

package extension VC {
    struct Offset: Sendable, Hashable {
        package let x: Unit
        package let y: Unit
    }
}

package extension VC.Offset {
    var isZero: Bool {
        x.isZero && y.isZero
    }
}
