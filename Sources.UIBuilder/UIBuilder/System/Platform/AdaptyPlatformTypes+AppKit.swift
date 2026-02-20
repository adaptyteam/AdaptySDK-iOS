//
//  AdaptyPlatformTypes+AppKit.swift
//  AdaptyUIBuilder
//
//  Created by Nikita Kupriyanov on 18.02.2026.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit

public extension AdaptyPlatformImage {
    init(nsImage: NSImage) {
        self.init(nsImage)
    }

    var nsImage: NSImage {
        native
    }
}

public extension AdaptyPlatformColor {
    init(nsColor: NSColor) {
        self.init(nsColor)
    }

    var nsColor: NSColor {
        native
    }
}

public extension AdaptyPlatformFont {
    init(nsFont: NSFont) {
        self.init(nsFont)
    }

    var nsFont: NSFont {
        native
    }
}

#endif
