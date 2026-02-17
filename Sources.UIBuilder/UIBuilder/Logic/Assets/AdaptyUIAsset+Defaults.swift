//
//  AdaptyUIAsset+Defaults.swift
//  Adapty
//
//  Created by Alex Goncharov on 15/01/2026.
//

import SwiftUI

extension Double {
    static var adaptyDefaultFontSize: Double { 15.0 }
}

extension VC.Asset {
    static var defaultNavigatorBackground: Self {
        .solidColor(.black)
    }

    static var defaultScreenBackground: Self {
        .solidColor(.black)
    }
}

extension Color {
    static var defaultNavigatorColor: Self {
        .black
    }
}

#if canImport(UIKit)

import UIKit

extension UIFont {
    static var adaptyDefaultFont: UIFont {
        .systemFont(ofSize: Double.adaptyDefaultFontSize)
    }
}

extension UIColor {
    static var adaptyDefaultTextColor: UIColor { .darkText }
}

#endif
