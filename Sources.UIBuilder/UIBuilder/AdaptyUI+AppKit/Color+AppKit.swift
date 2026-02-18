//
//  Color+AppKit.swift
//  AdaptyUIBuilder
//
//  Created by Nikita Kupriyanov on 18.02.2026.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension SwiftUI.Color {
    var nsColor: NSColor? {
        NSColor(self)
    }
}

#endif
