//
//  SwiftUI+ScrollView.swift
//
//
//  Created by Aleksey Goncharov on 24.06.2024.
//

#if canImport(UIKit) || canImport(AppKit)

import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension View {
    @ViewBuilder
    func scrollIndicatorsHidden_compatible() -> some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, visionOS 1.0, *) {
            scrollIndicators(.hidden)
        } else {
            self
        }
    }
}

#endif
