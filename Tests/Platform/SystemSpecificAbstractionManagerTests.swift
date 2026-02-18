#if canImport(Testing)

@testable import AdaptyUIBuilder
import SwiftUI
import Testing

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

struct PlatformSystemSpecificAbstractionManagerTests {
    @Test
    func legacyCustomAssetConstructorsRemainAvailable() {
        let url = URL(string: "https://adapty.io")!

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
        let preview = NSImage(size: CGSize(width: 8, height: 8))
        _ = AdaptyUICustomImageAsset.remote(url: url, preview: nil)
        _ = AdaptyUICustomImageAsset.remote(url: url, preview: preview)
        _ = AdaptyUICustomImageAsset.nsImage(value: preview)
        _ = AdaptyUICustomAsset.font(NSFont.systemFont(ofSize: 12))
#elseif canImport(UIKit)
        let preview = UIImage()
        _ = AdaptyUICustomImageAsset.remote(url: url, preview: nil)
        _ = AdaptyUICustomImageAsset.remote(url: url, preview: preview)
        _ = AdaptyUICustomImageAsset.uiImage(value: preview)
        _ = AdaptyUICustomAsset.font(UIFont.systemFont(ofSize: 12))
#endif

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
        let platformImage = AdaptyPlatformImage(nsImage: NSImage(size: CGSize(width: 8, height: 8)))
#elseif canImport(UIKit)
        let platformImage = AdaptyPlatformImage(uiImage: UIImage())
#else
        return
#endif
        _ = AdaptyUICustomImageAsset.remote(url: url, preview: platformImage)
        _ = AdaptyUICustomImageAsset.platformImage(value: platformImage)
    }

    @Test
    func colorBridgesBetweenPlatformAndSwiftUI() {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) else {
            return
        }

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
        let platformColor = AdaptyPlatformColor(nsColor: .systemRed)
#elseif canImport(UIKit)
        let platformColor = AdaptyPlatformColor(uiColor: .systemRed)
#else
        return
#endif

        let swiftUIColor = SystemSpecificAbstractionManager.swiftUIColor(from: platformColor)
        let bridgedBack = SystemSpecificAbstractionManager.platformColor(from: swiftUIColor)
        #expect(bridgedBack != nil)
    }

    @Test
    func imageAndFontHelpersReturnPlatformCompatibleValues() {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) else {
            return
        }

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
        let image = NSImage(size: CGSize(width: 12, height: 12))
        image.lockFocus()
        NSColor.white.setFill()
        NSBezierPath(rect: CGRect(x: 0, y: 0, width: 12, height: 12)).fill()
        image.unlockFocus()

        let baseImage = AdaptyPlatformImage(nsImage: image)
        let baseFont = AdaptyPlatformFont(nsFont: .systemFont(ofSize: 12))
#elseif canImport(UIKit)
        let image = UIGraphicsImageRenderer(size: CGSize(width: 12, height: 12)).image { context in
            UIColor.white.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 12, height: 12))
        }

        let baseImage = AdaptyPlatformImage(uiImage: image)
        let baseFont = AdaptyPlatformFont(uiFont: .systemFont(ofSize: 12))
#else
        return
#endif

        let resized = SystemSpecificAbstractionManager.resizedImage(baseImage, to: CGSize(width: 4, height: 4))
        #expect(resized.native.size.width > 0)
        #expect(resized.native.size.height > 0)

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
        let tint = AdaptyPlatformColor(nsColor: .systemBlue)
#elseif canImport(UIKit)
        let tint = AdaptyPlatformColor(uiColor: .systemBlue)
#else
        return
#endif

        let tinted = SystemSpecificAbstractionManager.tintedImage(resized, with: tint)
        _ = SystemSpecificAbstractionManager.swiftUIImage(from: tinted)

        let resizedFont = SystemSpecificAbstractionManager.withSize(baseFont, size: 18)
        #expect(resizedFont.native.pointSize == 18)
        _ = SystemSpecificAbstractionManager.swiftUIFont(from: resizedFont)
    }
}

#endif
