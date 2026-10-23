//
//  Plugin.swift
//  Adapty
//
//  Created by Aleksey Goncharov on 13.11.2024.
//

import Adapty
import AdaptyUIBuilder

package enum AdaptyUIViewPresentationStyle: String, Codable {
    case fullScreen = "full_screen"
    case pageSheet = "page_sheet"
}

#if canImport(UIKit)

import UIKit

extension UIViewController {
    var isOrContainsAdaptyController: Bool {
        guard #available(iOS 16.0, macOS 13.0, visionOS 1.0, *) else { return false }
        guard let presentedViewController = presentedViewController else {
            return self is AdaptyFlowController
        }
        return presentedViewController is AdaptyFlowController
    }
}

fileprivate extension UIWindow {
    var topViewController: UIViewController? {
        var topViewController = rootViewController

        while let presentedController = topViewController?.presentedViewController {
            topViewController = presentedController
        }

        return topViewController
    }
}

fileprivate extension UIApplication {
    var firstKeyWindow: UIWindow? {
        connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first
    }
}

extension AdaptyUIViewPresentationStyle {
    var uiKitPresentationStyle: UIModalPresentationStyle {
        switch self {
        case .fullScreen: .overFullScreen
        case .pageSheet: .pageSheet
        }
    }
}

#endif

package extension AdaptyUI {
    @MainActor
    class Plugin {
#if canImport(UIKit)
        @available(*, deprecated, message: "Starting Adapty SDK 4.0.0, Onboarding Feature is deprecated. Please consider migrating to Flows")
        private static var onboardingControllers = [String: AdaptyOnboardingController]()

        @available(*, deprecated, message: "Starting Adapty SDK 4.0.0, Onboarding Feature is deprecated. Please consider migrating to Flows")
        private static func cacheOnboardingController(_ controller: AdaptyOnboardingController, id: String) {
            onboardingControllers[id] = controller
        }

        @available(*, deprecated, message: "Starting Adapty SDK 4.0.0, Onboarding Feature is deprecated. Please consider migrating to Flows")
        private static func deleteCachedOnboardingController(_ id: String) {
            onboardingControllers.removeValue(forKey: id)
        }

        @available(*, deprecated, message: "Starting Adapty SDK 4.0.0, Onboarding Feature is deprecated. Please consider migrating to Flows")
        private static func cachedOnboardingController(_ id: String) -> AdaptyOnboardingController? {
            onboardingControllers[id]
        }
#endif
        
#if canImport(UIKit)
        /// Flow views are rendered on iOS 16 and later; on older versions every flow
        /// view request fails with ``AdaptyUIError/platformNotSupported``. Tests turn
        /// it off to reach that branch on a newer runtime.
        @TaskLocal
        package static var isFlowRenderingSupported: Bool = {
            if #available(iOS 16.0, macOS 13.0, visionOS 1.0, *) { true } else { false }
        }()

        package static func createFlowView(
            flow: AdaptyFlow,
            locale: String?,
            customLayoutId: String?,
            loadTimeout: TimeInterval?,
            preloadProducts: Bool,
            tagResolver: AdaptyUITagResolver?,
            timerResolver: AdaptyTimerResolver?,
            assetsResolver: AdaptyUIAssetsResolver?,
            observerModeResolver: AdaptyObserverModeResolver? = nil,
            systemRequestsHandler: AdaptyUISystemRequestsHandler? = nil
        ) async throws -> AdaptyUI.FlowView {
            guard isFlowRenderingSupported, #available(iOS 16.0, macOS 13.0, visionOS 1.0, *) else {
                throw AdaptyUIError.platformNotSupported
            }

            let configuration = try await AdaptyUI.getFlowConfiguration(
                forFlow: flow,
                locale: locale,
                customLayoutId: customLayoutId,
                loadTimeout: loadTimeout,
                observerModeResolver: observerModeResolver,
                tagResolver: tagResolver,
                timerResolver: timerResolver,
                assetsResolver: assetsResolver,
                systemRequestsHandler: systemRequestsHandler
            )

            // Products already load alongside the UI schema; preloading only
            // waits for that first attempt. A failure doesn't break view
            // creation: the view model retries on its own. Same contract as
            // the Android plugin.
            if preloadProducts {
                await configuration.productsViewModel.waitForProducts()
            }

            let vc = try AdaptyUI.paywallControllerWithUniversalDelegate(configuration)
            cachePaywallController(vc, id: vc.id)
            return vc.toAdaptyUIView()
        }
#endif

        package static func presentFlowView(
            viewId: String,
            presentationStyle: AdaptyUIViewPresentationStyle?
        ) async throws {
#if canImport(UIKit)
            guard isFlowRenderingSupported, #available(iOS 16.0, macOS 13.0, visionOS 1.0, *) else {
                throw AdaptyUIError.platformNotSupported
            }

            guard let vc = cachedPaywallController(viewId) else {
                throw AdaptyError(AdaptyUI.PluginError.viewNotFound(viewId))
            }
            
            guard let rootVC = UIApplication.shared.firstKeyWindow?.topViewController else {
                throw AdaptyError(AdaptyUI.PluginError.viewPresentationError(viewId))
            }
            
            guard !rootVC.isOrContainsAdaptyController else {
                throw AdaptyError(AdaptyUI.PluginError.viewAlreadyPresented(viewId))
            }
            
            vc.modalPresentationCapturesStatusBarAppearance = true
            vc.modalPresentationStyle = presentationStyle?.uiKitPresentationStyle ?? .overFullScreen
            
            await withCheckedContinuation { continuation in
                rootVC.present(vc, animated: true) {
                    continuation.resume()
                }
            }
#else
            throw AdaptyUIError.platformNotSupported
#endif
        }
        
        package static func dismissFlowView(
            viewId: String,
            destroy: Bool
        ) async throws {
#if canImport(UIKit)
            guard isFlowRenderingSupported, #available(iOS 16.0, macOS 13.0, visionOS 1.0, *) else {
                throw AdaptyUIError.platformNotSupported
            }

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
        
        package static func destroyFlowView(
            viewId: String
        ) async throws {
#if canImport(UIKit)
            guard isFlowRenderingSupported, #available(iOS 16.0, macOS 13.0, visionOS 1.0, *) else {
                throw AdaptyUIError.platformNotSupported
            }

            guard let vc = cachedPaywallController(viewId) else {
                throw AdaptyError(AdaptyUI.PluginError.viewNotFound(viewId))
            }

            deleteCachedPaywallController(viewId)

            if vc.presentingViewController != nil {
                Log.ui.warn("destroyFlowView: view \(viewId) is still presented, use dismissFlowView(destroy: true) instead")
                vc.dismiss(animated: false)
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
            guard isFlowRenderingSupported, #available(iOS 16.0, macOS 13.0, visionOS 1.0, *) else {
                throw AdaptyUIError.platformNotSupported
            }

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

#if canImport(UIKit)

@available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
extension AdaptyUI.Plugin {
    private static var paywallControllers = [String: AdaptyFlowController]()

    private static func cachePaywallController(_ controller: AdaptyFlowController, id: String) {
        paywallControllers[id] = controller
    }

    private static func deleteCachedPaywallController(_ id: String) {
        paywallControllers.removeValue(forKey: id)
    }

    private static func cachedPaywallController(_ id: String) -> AdaptyFlowController? {
        paywallControllers[id]
    }
}

#endif

@MainActor
@available(*, deprecated, message: "Starting Adapty SDK 4.0.0, Onboarding Feature is deprecated. Please consider migrating to Flows")
package extension AdaptyUI.Plugin {
    static func createOnboardingView(
        onboarding: AdaptyOnboarding,
        externalUrlsPresentation: AdaptyWebPresentation
    ) async throws -> AdaptyUI.OnboardingView {
#if canImport(UIKit)
        let configuration = try AdaptyUI.getOnboardingConfiguration(
            forOnboarding: onboarding,
            externalUrlsPresentation: externalUrlsPresentation
        )
        let vc = try AdaptyUI.onboardingControllerWithUniversalDelegate(
            configuration
        )
            
        cacheOnboardingController(vc, id: vc.id)
        return vc.toAdaptyUIView()
#else
        throw AdaptyUIError.platformNotSupported
#endif
    }
    
    static func presentOnboardingView(
        viewId: String,
        presentationStyle: AdaptyUIViewPresentationStyle?
    ) async throws {
#if canImport(UIKit)
        guard let vc = cachedOnboardingController(viewId) else {
            throw AdaptyError(AdaptyUI.PluginError.viewNotFound(viewId))
        }
        
        guard let rootVC = UIApplication.shared.firstKeyWindow?.topViewController else {
            throw AdaptyError(AdaptyUI.PluginError.viewPresentationError(viewId))
        }
        
        guard !rootVC.isOrContainsAdaptyController else {
            throw AdaptyError(AdaptyUI.PluginError.viewAlreadyPresented(viewId))
        }
        
        vc.modalPresentationCapturesStatusBarAppearance = true
        vc.modalPresentationStyle = presentationStyle?.uiKitPresentationStyle ?? .overFullScreen
        
        await withCheckedContinuation { continuation in
            rootVC.present(vc, animated: true) {
                continuation.resume()
            }
        }
#else
        throw AdaptyUIError.platformNotSupported
#endif
    }
    
    static func dismissOnboardingView(
        viewId: String,
        destroy: Bool
    ) async throws {
#if canImport(UIKit)
        guard let vc = cachedOnboardingController(viewId) else {
            throw AdaptyError(AdaptyUI.PluginError.viewNotFound(viewId))
        }

        await withCheckedContinuation { continuation in
            vc.dismiss(animated: true) {
                if destroy {
                    deleteCachedOnboardingController(viewId)
                }
                continuation.resume()
            }
        }
#else
        throw AdaptyUIError.platformNotSupported
#endif
    }
}
