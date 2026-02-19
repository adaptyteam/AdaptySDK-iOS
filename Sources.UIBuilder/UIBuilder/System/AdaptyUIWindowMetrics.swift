//
//  AdaptyUIWindowMetrics.swift
//  AdaptyUIBuilder
//
//  Created by Nikita Kupriyanov on 20.02.2026.
//

import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
package struct AdaptyUIWindowMetrics: Sendable, Equatable {
    package let safeAreaInsets: EdgeInsets
    package let windowSize: CGSize

    package init(
        safeAreaInsets: EdgeInsets,
        windowSize: CGSize
    ) {
        self.safeAreaInsets = safeAreaInsets
        self.windowSize = windowSize
    }
}
