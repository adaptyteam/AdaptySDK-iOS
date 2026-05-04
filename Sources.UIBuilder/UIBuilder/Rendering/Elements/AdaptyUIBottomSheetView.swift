//
//  AdaptyUIBottomSheetView.swift
//  AdaptyUIBuilder
//
//  Created by Aleksey Goncharov on 18.06.2024.
//

#if canImport(UIKit)

import SwiftUI

@MainActor // TODO: x move out
extension AdaptyUIBuilder {
    static var mainScreenBounds: CGRect {
#if os(visionOS)
        UIApplication.shared.windows.first?.bounds ?? .zero
#else
        UIScreen.main.bounds
#endif
    }
}
#endif
