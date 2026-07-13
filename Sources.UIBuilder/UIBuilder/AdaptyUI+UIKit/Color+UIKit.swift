//
//  Color+UIKit.swift
//  AdaptyUIBuilder
//
//  Created by Alexey Goncharov on 6/4/25.
//

#if canImport(UIKit)

import SwiftUI
import UIKit

extension SwiftUI.Color {
    var uiColor: UIColor? { UIColor(self) }
}

#endif
