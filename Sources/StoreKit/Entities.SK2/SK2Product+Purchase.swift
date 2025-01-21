//
//  SK2Product+Purchase.swift
//  AdaptySDK
//
//  Created by Alexey Goncharov on 15.01.2025.
//

import StoreKit

#if os(iOS) || os(tvOS) || VISION_OS || targetEnvironment(macCatalyst) || os(watchOS)
import UIKit
#endif

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension SK2Product {
    func unfPurchase(
        options: Set<Product.PurchaseOption> = []
    ) async throws -> PurchaseResult {
#if VISION_OS
        if let scene = await UIApplication.shared.activeScene {
            try await purchase(confirmIn: scene, options: options)
        } else {
            throw AdaptyError.cantMakePayments()
        }
#elseif(os(iOS) || os(tvOS)) && compiler(>=6.0.3)
        if #available(iOS 18.2, tvOS 18.2, *),
           let viewController = await UIApplication.shared.topPresentedController
        {
            try await purchase(confirmIn: viewController, options: options)
        } else {
            try await purchase(options: options)
        }
#else
        try await purchase(options: options)
#endif
    }
}

#if os(iOS) || os(tvOS) || VISION_OS || targetEnvironment(macCatalyst) || os(watchOS)
@MainActor
private extension UIApplication {
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
private extension UIViewController {
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
