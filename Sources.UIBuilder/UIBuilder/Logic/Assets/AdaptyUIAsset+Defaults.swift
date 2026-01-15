//
//  AdaptyUIAsset+Defaults.swift
//  Adapty
//
//  Created by Alex Goncharov on 15/01/2026.
//

#if canImport(UIKit)

import UIKit

extension UIFont {
    static var adaptyDefaultFont: UIFont { .systemFont(ofSize: 15.0) }
}

extension UIColor {
    static var adaptyDefaultTextColor: UIColor { .darkText }
}

#endif

import SwiftUI

extension VC.Asset {
    static var defaultScreenBackground: Self {
        .solidColor(.black)
    }
}
