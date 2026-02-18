//
//  SystemConstantsManager.swift
//  AdaptyUIBuilder
//
//  Created by Nikita Kupriyanov on 18.02.2026.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#if os(iOS)
import SafariServices
#endif
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
        await openExternalURL(url, presentation: .browserOutApp)
    }

    @discardableResult
    package static func openExternalURL(
        _ url: URL,
        presentation: VC.WebOpenInParameter
    ) async -> Bool {
        #if canImport(UIKit)
        return await openExternalURLiOS(url, presentation: presentation)
        #elseif canImport(AppKit) && !targetEnvironment(macCatalyst)
        return openExternalURLmacOS(url, presentation: presentation)
        #else
        return false
        #endif
    }

    package static func resolvedPresentationForCurrentPlatform(
        _ presentation: VC.WebOpenInParameter,
        url: URL
    ) -> VC.WebOpenInParameter {
#if os(iOS)
        guard presentation == .browserInApp else { return presentation }
        return url.supportsInAppBrowserOnIOS ? .browserInApp : .browserOutApp
#else
        return .browserOutApp
#endif
    }

    #if canImport(UIKit)
    private static func openExternalURLiOS(
        _ url: URL,
        presentation: VC.WebOpenInParameter
    ) async -> Bool {
        let resolvedPresentation = resolvedPresentationForCurrentPlatform(
            presentation,
            url: url
        )

        if presentation == .browserInApp,
           resolvedPresentation == .browserOutApp {
            Log.ui.warn("In-app browser is available only for http/https URLs on iOS. Falling back to external browser.")
        }

        switch resolvedPresentation {
        case .browserOutApp:
            return await openExternalURLiOSExternal(url)
        case .browserInApp:
            #if os(iOS)
            return await openExternalURLiOSInApp(url)
            #else
            Log.ui.warn("In-app browser for external URL is not available in this context. Falling back to external browser.")
            return await openExternalURLiOSExternal(url)
            #endif
        }
    }

    private static func openExternalURLiOSExternal(_ url: URL) async -> Bool {
        return await withCheckedContinuation { continuation in
            UIApplication.shared.open(url, options: [:]) { success in
                continuation.resume(returning: success)
            }
        }
    }

    #if os(iOS)
    private static func openExternalURLiOSInApp(_ url: URL) async -> Bool {
        guard let topViewController = UIApplication.shared.topPresentedController else {
            Log.ui.warn("Could not resolve top presented controller for in-app browser. Falling back to external browser.")
            return await openExternalURLiOSExternal(url)
        }

        let safariViewController = SFSafariViewController(url: url)
        let isPresentedInApp = await withCheckedContinuation { continuation in
            topViewController.present(safariViewController, animated: true) {
                let presented =
                    topViewController.presentedViewController === safariViewController ||
                    safariViewController.presentingViewController === topViewController
                continuation.resume(returning: presented)
            }
        }

        if isPresentedInApp {
            return true
        } else {
            Log.ui.warn("Failed to present in-app browser. Falling back to external browser.")
            return await openExternalURLiOSExternal(url)
        }
    }
    #endif
    #endif

    #if canImport(AppKit) && !targetEnvironment(macCatalyst)
    private static func openExternalURLmacOS(
        _ url: URL,
        presentation: VC.WebOpenInParameter
    ) -> Bool {
        if presentation == .browserInApp {
            Log.ui.warn("In-app browser for external URL is not available on native macOS. Falling back to external browser.")
        }

        return NSWorkspace.shared.open(url)
    }
    #endif
}

#if os(iOS)
@MainActor
private extension UIApplication {
    private var activeScene: UIWindowScene? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })
    }

    var topPresentedController: UIViewController? {
        activeScene?
            .windows
            .first(where: { $0.isKeyWindow })?
            .rootViewController?
            .topPresentedController()
    }
}

@MainActor
private extension UIViewController {
    func topPresentedController() -> UIViewController {
        var topController: UIViewController = self

        while let presented = topController.presentedViewController {
            topController = presented
        }

        return topController.drillDownToChild()
    }

    private func drillDownToChild() -> UIViewController {
        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController?.drillDownToChild() ?? navigationController
        }

        if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.drillDownToChild() ?? tabBarController
        }

        return self
    }
}

private extension URL {
    var supportsInAppBrowserOnIOS: Bool {
        guard let scheme = scheme?.lowercased() else {
            return false
        }

        return scheme == "http" || scheme == "https"
    }
}
#endif
