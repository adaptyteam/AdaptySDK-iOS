//
//  Plugin.swift
//  Adapty
//
//  Created by Aleksey Goncharov on 13.11.2024.
//

import Adapty
import Foundation

#if canImport(UIKit)
import UIKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension UIViewController {
    var isOrContainsAdaptyController: Bool {
        guard let presentedViewController = presentedViewController else {
            return self is AdaptyPaywallController
        }
        return presentedViewController is AdaptyPaywallController
    }
}

extension UIWindow {
    fileprivate var topViewController: UIViewController? {
        var topViewController = rootViewController
    
        while let presentedController = topViewController?.presentedViewController {
            topViewController = presentedController
        }
        
        return topViewController
    }
}

#endif

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
package extension AdaptyUI {
    @MainActor
    class Plugin {
#if canImport(UIKit)
        
        private static var paywallControllers = [UUID: AdaptyPaywallController]()
        
        private static func cachePaywallController(_ controller: AdaptyPaywallController, id: UUID) {
            paywallControllers[id] = controller
        }
        
        private static func deleteCachedPaywallController(_ id: String) {
            guard let uuid = UUID(uuidString: id) else { return }
            paywallControllers.removeValue(forKey: uuid)
        }
        
        private static func cachedPaywallController(_ id: String) -> AdaptyPaywallController? {
            guard let uuid = UUID(uuidString: id) else { return nil }
            return paywallControllers[uuid]
        }
#endif
        
        package static func createView(
            paywall: AdaptyPaywall,
            loadTimeout: TimeInterval?,
            preloadProducts: Bool,
            tagResolver: AdaptyTagResolver?,
            timerResolver: AdaptyTimerResolver?
        ) async throws -> AdaptyUI.View {
#if canImport(UIKit)
            let products: [AdaptyPaywallProduct]?
            
            if preloadProducts {
                products = try await Adapty.getPaywallProducts(paywall: paywall)
            } else {
                products = nil
            }
            
            let configuration = try await AdaptyUI.getPaywallConfiguration(
                forPaywall: paywall,
                loadTimeout: loadTimeout,
                products: products,
                observerModeResolver: nil,
                tagResolver: tagResolver,
                timerResolver: timerResolver
            )
            
            let vc = try AdaptyUI.paywallControllerWithUniversalDelegate(configuration)
            cachePaywallController(vc, id: vc.id)
            return vc.toAdaptyUIView()
#else
            throw AdaptyUIError.platformNotSupported
#endif
        }

        package static func presentView(
            viewId: String
        ) async throws {
#if canImport(UIKit)
            guard let vc = cachedPaywallController(viewId) else {
                throw AdaptyError(AdaptyUI.PluginError.viewNotFound(viewId))
            }
            
            guard let rootVC = UIApplication.shared.windows.first?.topViewController else {
                throw AdaptyError(AdaptyUI.PluginError.viewPresentationError(viewId))
            }
            
            guard !rootVC.isOrContainsAdaptyController else {
                throw AdaptyError(AdaptyUI.PluginError.viewAlreadyPresented(viewId))
            }
            
            vc.modalPresentationCapturesStatusBarAppearance = true
            vc.modalPresentationStyle = .overFullScreen
            
            await withCheckedContinuation { continuation in
                rootVC.present(vc, animated: true) {
                    continuation.resume()
                }
            }
#else
            throw AdaptyUIError.platformNotSupported
#endif
        }
        
        package static func dismissView(
            viewId: String,
            destroy: Bool
        ) async throws {
#if canImport(UIKit)
            guard let vc = cachedPaywallController(viewId) else {
                throw AdaptyError(AdaptyUI.PluginError.viewNotFound(viewId))
            }

            await withCheckedContinuation { continuation in
                vc.dismiss(animated: true) {
                    if destroy {
                        deleteCachedPaywallController(viewId)
                    }
                    continuation.resume()
                }
            }
#else
            throw AdaptyUIError.platformNotSupported
#endif
        }
        
        package static func showDialog(
            viewId: String,
            configuration: AdaptyUI.DialogConfiguration
        ) async throws -> DialogActionType {
#if canImport(UIKit)
            guard let vc = cachedPaywallController(viewId) else {
                throw AdaptyError(AdaptyUI.PluginError.viewNotFound(viewId))
            }
            
            return await withCheckedContinuation { continuation in
                vc.showDialog(
                    configuration,
                    defaultActionHandler: {
                        continuation.resume(with: .success(.primary))
                    }, secondaryActionHandler: {
                        continuation.resume(with: .success(.secondary))
                    }
                )
            }
#else
            throw AdaptyUIError.platformNotSupported
#endif
        }
    }
    
    enum DialogActionType {
        case primary
        case secondary
    }
}
