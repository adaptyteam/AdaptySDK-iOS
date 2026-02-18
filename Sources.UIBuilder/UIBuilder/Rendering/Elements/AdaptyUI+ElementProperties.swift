//
//  AdaptyUI+ElementProperties.swift
//  AdaptyUIBuilder
//
//  Created by Aleksey Goncharov on 3.4.24..
//


import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension VC.Point {
    var unitPoint: UnitPoint { UnitPoint(x: x, y: y) }
}
