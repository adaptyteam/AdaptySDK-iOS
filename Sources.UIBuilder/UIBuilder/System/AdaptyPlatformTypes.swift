//
//  AdaptyPlatformTypes.swift
//  AdaptyUIBuilder
//
//  Created by Nikita Kupriyanov on 18.02.2026.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
public typealias AdaptyNativeImage = UIImage
public typealias AdaptyNativeColor = UIColor
public typealias AdaptyNativeFont = UIFont
#elseif canImport(AppKit)
import AppKit
public typealias AdaptyNativeImage = NSImage
public typealias AdaptyNativeColor = NSColor
public typealias AdaptyNativeFont = NSFont
#endif

public struct AdaptyPlatformImage: @unchecked Sendable {
    package let native: AdaptyNativeImage

    public init(_ native: AdaptyNativeImage) {
        self.native = native
    }
}

public struct AdaptyPlatformColor: @unchecked Sendable {
    package let native: AdaptyNativeColor

    public init(_ native: AdaptyNativeColor) {
        self.native = native
    }
}

public struct AdaptyPlatformFont: @unchecked Sendable {
    package let native: AdaptyNativeFont

    public init(_ native: AdaptyNativeFont) {
        self.native = native
    }

    public func withSize(_ size: Double) -> AdaptyPlatformFont {
#if canImport(UIKit)
        AdaptyPlatformFont(native.withSize(size))
#else
        AdaptyPlatformFont(native.withSize(size))
#endif
    }
}
