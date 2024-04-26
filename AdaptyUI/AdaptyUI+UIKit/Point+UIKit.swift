//
//  Point+UIKit.swift
//
//
//  Created by Alexey Goncharov on 10.8.23..
//

import Adapty
import UIKit

extension AdaptyUI.Point {
    var cgPoint: CGPoint { .init(x: x, y: y) }
}
