//
//  AdaptyUIBuilder+OpenURL.swift
//  AdaptyUIBuilder
//
//  Created by Alexey Goncharov on 06.05.2026.
//

#if canImport(UIKit)

import Foundation
import UIKit

#if canImport(SafariServices) && !os(visionOS)
import SafariServices
#endif

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
package extension URL {
    func open(in presentation: AdaptyUIBuilder.WebPresentation) {
        switch presentation {
        case .externalBrowser:
            UIApplication.shared.open(self, options: [:])
        case .inAppBrowser:
            #if canImport(SafariServices) && os(iOS)
            guard let topViewController = UIApplication.shared.topPresentedController else {
                UIApplication.shared.open(self, options: [:])
                return
            }
            topViewController.present(SFSafariViewController(url: self), animated: true)
            #else
            UIApplication.shared.open(self, options: [:])
            #endif
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
private extension UIApplication {
    var topPresentedController: UIViewController? {
        let scene = connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })

        return scene?
            .windows
            .first(where: { $0.isKeyWindow })?
            .rootViewController?
            .topPresentedController()
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
private extension UIViewController {
    func topPresentedController() -> UIViewController {
        var top: UIViewController = self
        while let presented = top.presentedViewController {
            top = presented
        }
        return top.drillDownToChild()
    }

    private func drillDownToChild() -> UIViewController {
        if let nav = self as? UINavigationController {
            return nav.visibleViewController?.drillDownToChild() ?? nav
        }
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.drillDownToChild() ?? tab
        }
        return self
    }
}

#endif
