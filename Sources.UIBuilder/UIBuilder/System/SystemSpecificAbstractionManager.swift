//
//  SystemSpecificAbstractionManager.swift
//  AdaptyUIBuilder
//
//  Created by Nikita Kupriyanov on 18.02.2026.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
package enum SystemSpecificAbstractionManager {
    package static func image(named name: String) -> AdaptyPlatformImage? {
#if canImport(UIKit)
        guard let image = UIImage(named: name) else { return nil }
        return AdaptyPlatformImage(image)
#elseif canImport(AppKit)
        guard let image = NSImage(named: name) else { return nil }
        return AdaptyPlatformImage(image)
#else
        return nil
#endif
    }

    package static func image(from data: Data) -> AdaptyPlatformImage? {
#if canImport(UIKit)
        guard let image = UIImage(data: data) else { return nil }
        return AdaptyPlatformImage(image)
#elseif canImport(AppKit)
        guard let image = NSImage(data: data) else { return nil }
        return AdaptyPlatformImage(image)
#else
        return nil
#endif
    }

    package static func swiftUIImage(from image: AdaptyPlatformImage) -> Image {
#if canImport(UIKit)
        Image(uiImage: image.native)
#elseif canImport(AppKit)
        Image(nsImage: image.native)
#else
        Image(systemName: "xmark")
#endif
    }

    package static func swiftUIColor(from color: AdaptyPlatformColor) -> Color {
#if canImport(UIKit)
        Color(color.native)
#elseif canImport(AppKit)
        Color(nsColor: color.native)
#else
        Color.clear
#endif
    }

    package static func platformColor(from color: Color) -> AdaptyPlatformColor? {
#if canImport(UIKit)
        guard let uiColor = color.uiColor else { return nil }
        return AdaptyPlatformColor(uiColor)
#elseif canImport(AppKit)
        guard let nsColor = color.nsColor else { return nil }
        return AdaptyPlatformColor(nsColor)
#else
        return nil
#endif
    }

    package static func swiftUIFont(from font: AdaptyPlatformFont) -> Font {
#if canImport(UIKit)
        Font(font.native)
#elseif canImport(AppKit)
        Font(font.native)
#else
        Font.body
#endif
    }

    package static func withSize(_ font: AdaptyPlatformFont, size: Double) -> AdaptyPlatformFont {
        AdaptyPlatformFont(font.native.withSize(size))
    }

    package static func resizedImage(_ image: AdaptyPlatformImage, to size: CGSize) -> AdaptyPlatformImage {
#if canImport(UIKit)
        let resized = UIGraphicsImageRenderer(size: size).image { _ in
            image.native.draw(in: CGRect(origin: .zero, size: size))
        }

        return AdaptyPlatformImage(resized.withRenderingMode(image.native.renderingMode))
#elseif canImport(AppKit)
        let resized = NSImage(size: size)
        resized.lockFocus()
        image.native.draw(
            in: CGRect(origin: .zero, size: size),
            from: .zero,
            operation: .copy,
            fraction: 1.0
        )
        resized.unlockFocus()
        return AdaptyPlatformImage(resized)
#else
        image
#endif
    }

    package static func tintedImage(_ image: AdaptyPlatformImage, with color: AdaptyPlatformColor) -> AdaptyPlatformImage {
#if canImport(UIKit)
        let tinted = image.native
            .withRenderingMode(.alwaysTemplate)
            .withTintColor(color.native, renderingMode: .alwaysTemplate)

        return AdaptyPlatformImage(tinted)
#elseif canImport(AppKit)
        let tinted = image.native.copy() as? NSImage ?? image.native
        tinted.lockFocus()
        color.native.set()
        let imageRect = CGRect(origin: .zero, size: tinted.size)
        imageRect.fill(using: .sourceAtop)
        tinted.unlockFocus()
        return AdaptyPlatformImage(tinted)
#else
        image
#endif
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
package typealias SystemSpecificAbsractionManager = SystemSpecificAbstractionManager
