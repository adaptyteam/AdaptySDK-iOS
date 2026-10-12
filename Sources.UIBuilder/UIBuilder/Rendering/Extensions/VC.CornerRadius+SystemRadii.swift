//
//  VC.CornerRadius+SystemRadii.swift
//
//
//  Created by Aleksey Goncharov on 22.05.2024.
//

#if canImport(UIKit)

import SwiftUI

@available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
extension VC.CornerRadius {
    var systemRadii: RectangleCornerRadii {
        RectangleCornerRadii(
            topLeading: topLeading,
            bottomLeading: bottomLeading,
            bottomTrailing: bottomTrailing,
            topTrailing: topTrailing
        )
    }
}

#endif
