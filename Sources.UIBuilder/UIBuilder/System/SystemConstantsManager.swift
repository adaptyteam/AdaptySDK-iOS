//
//  SystemConstantsManager.swift
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

@MainActor
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
package enum SystemConstantsManager {
    package static var mainScreenBounds: CGRect {
#if canImport(UIKit)
        #if os(visionOS)
        UIApplication.shared.windows.first?.bounds ?? .zero
        #else
        UIScreen.main.bounds
        #endif
#elseif canImport(AppKit)
        NSScreen.main?.frame ?? .zero
#else
        .zero
#endif
    }

    package static var systemBackgroundColor: Color {
#if canImport(UIKit)
        Color(UIColor.systemBackground)
#elseif canImport(AppKit)
        Color(nsColor: .windowBackgroundColor)
#else
        Color.clear
#endif
    }

    @discardableResult
    package static func openExternalURL(_ url: URL) async -> Bool {
#if canImport(UIKit)
        await withCheckedContinuation { continuation in
            UIApplication.shared.open(url, options: [:]) { success in
                continuation.resume(returning: success)
            }
        }
#elseif canImport(AppKit)
        NSWorkspace.shared.open(url)
#else
        false
#endif
    }

    @discardableResult
    package static func openExternalURL(
        _ url: URL,
        presentation _: VC.WebOpenInParameter
    ) async -> Bool {
        await openExternalURL(url)
    }
}
