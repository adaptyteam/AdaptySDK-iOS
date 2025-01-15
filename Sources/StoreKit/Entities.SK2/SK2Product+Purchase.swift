//
//  SK2Product+Purchase.swift
//  Adapty
//
//  Created by Alexey Goncharov on 1/15/25.
//

#if canImport(UIKit)

import UIKit

@MainActor
extension UIApplication {
    /// Returns the key `UIWindowScene` for the current application
    var activeScene: UIWindowScene? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })
    }

    /// Returns the top-most presented view controller starting from the root of the key window.
    var topPresentedController: UIViewController? {
        activeScene?
            .windows
            .first(where: { $0.isKeyWindow })?
            .rootViewController?
            .topPresentedController()
    }
}

@MainActor
extension UIViewController {
    /// Returns the top-most presented view controller from the current view controller.
    func topPresentedController() -> UIViewController {
        var topController: UIViewController = self

        while let presented = topController.presentedViewController {
            topController = presented
        }

        return topController.drillDownToChild()
    }

    /// Drills down into `UINavigationController` or `UITabBarController` to find the visible or selected child controller.
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

#endif
