//
//  Color+UIKit.swift
//  
//
//  Created by Alexey Goncharov on 10.8.23..
//

#if canImport(UIKit)

import Adapty
import UIKit

extension AdaptyUI.Color {
    var uiColor: UIColor { .init(red: red, green: green, blue: blue, alpha: alpha) }
}

#endif
