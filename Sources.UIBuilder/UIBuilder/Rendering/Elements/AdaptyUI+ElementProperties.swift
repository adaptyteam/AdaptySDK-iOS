//
//  AdaptyUI+ElementProperties.swift
//  AdaptyUIBuilder
//
//  Created by Aleksey Goncharov on 3.4.24..
//

#if canImport(UIKit)

import SwiftUI

extension VC.Point {
    var unitPoint: UnitPoint { UnitPoint(x: x, y: y) }
}

#endif
