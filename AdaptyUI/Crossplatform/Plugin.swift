//
//  Plugin.swift
//  Adapty
//
//  Created by Aleksey Goncharov on 13.11.2024.
//

import Adapty
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

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
package extension AdaptyUI {
    @MainActor
    class Plugin {
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
        
        package static func createView(
            paywall: AdaptyPaywall,
            loadTimeout: TimeInterval,
            preloadProducts: Bool,
            tagResolver: AdaptyTagResolver?,
            timerResolver: AdaptyTimerResolver?
        ) async throws -> AdaptyUI.View {
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
            
            let vc = try AdaptyUI.paywallController(
                with: configuration,
                delegate: PluginDelegate.shared
            )
            
            cachePaywallController(vc, id: vc.id)
            
            return vc.toView()
        }

        package static func presentView(
            viewId: String
        ) async throws {
            guard let vc = cachedPaywallController(viewId) else {
                throw AdaptyError(AdaptyUI.PluginError.viewNotFound(viewId))
            }
            
            guard let rootVC = UIApplication.shared.windows.first?.rootViewController else {
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
        }
        
        package static func dismissView(
            viewId: String,
            destroy: Bool
        ) async throws {
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
        }
        
        package static func showDialog(
            viewId: String,
            configuration: AdaptyUI.DialogConfiguration
        ) async throws -> Int {
            guard let vc = cachedPaywallController(viewId) else {
                throw AdaptyError(AdaptyUI.PluginError.viewNotFound(viewId))
            }
            
            return await withCheckedContinuation { continuation in
                vc.showDialog(
                    configuration,
                    defaultActionHandler: {
                        continuation.resume(with: .success(0))
                    }, secondaryActionHandler: {
                        continuation.resume(with: .success(1))
                    }
                )
            }
        }
    }
}
