//
//  Color+UIKit.swift
//  Adapty
//
//  Created by Alexey Goncharov on 6/4/25.
//

#if canImport(UIKit)

import SwiftUI
import UIKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension SwiftUI.Color {
    var uiColor: UIColor? { UIColor(self) }
}

#endif
