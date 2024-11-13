//
//  File.swift
//  Adapty
//
//  Created by Aleksey Goncharov on 13.11.2024.
//

import Adapty
import AdaptyUI
import Foundation

extension Adapty
{
    enum CrossplatformDelegateArgument: String
    {
        case view
        case action
        case product
        case profile
        case purchasedResult = "purchased_result"
        case error
        case configuration
    }
    
    enum CrossplatformDelegateMethod: String
    {
        case didLoadLatestProfile = "did_load_latest_profile"
        
        case paywallViewDidPerformAction = "paywall_view_did_perform_action"
        case paywallViewDidSelectProduct = "paywall_view_did_select_product"
        case paywallViewDidStartPurchase = "paywall_view_did_start_purchase"
        case paywallViewDidCancelPurchase = "paywall_view_did_cancel_purchase"
        case paywallViewDidFinishPurchase = "paywall_view_did_finish_purchase"
        case paywallViewDidFailPurchase = "paywall_view_did_fail_purchase"
        case paywallViewDidStartRestore = "paywall_view_did_start_restore"
        case paywallViewDidFinishRestore = "paywall_view_did_finish_restore"
        case paywallViewDidFailRestore = "paywall_view_did_fail_restore"
        case paywallViewDidFailRendering = "paywall_view_did_fail_rendering"
        case paywallViewDidFailLoadingProducts = "paywall_view_did_fail_loading_products"
    }
    
    public typealias CrossplatformDelegateListener = (String, [String: String]) -> Void
    
    @MainActor
    public static func initializeCrossplatformDelegate(
        listener: @escaping CrossplatformDelegateListener
    )
    {
        Adapty.delegate = PluginDelegate.shared
        PluginDelegate.shared.delegateListener = listener
    }
    
    @MainActor
    class PluginDelegate: NSObject
    {
        static let shared = PluginDelegate()
        
        var delegateListener: CrossplatformDelegateListener?
        
        func invokeMethod(
            _ method: CrossplatformDelegateMethod,
            arguments: [CrossplatformDelegateArgument: Encodable]
        )
        {
            do {
                let mappedArgs = try Dictionary(uniqueKeysWithValues: arguments.map
                                                { key, value in
                    (key.rawValue, try AdaptyPlugin.encoder.encode(value).asAdaptyJsonString)
                })

                delegateListener?(method.rawValue, mappedArgs)
            } catch {
                Log.plugin.error("Plugin encoding error: \(error.localizedDescription)")
            }
        }
    }
}

extension Adapty.PluginDelegate: AdaptyDelegate
{
    nonisolated func didLoadLatestProfile(_ profile: AdaptyProfile)
    {
        Task
        { @MainActor in
            invokeMethod(
                .didLoadLatestProfile,
                arguments: [
                    .profile: profile,
                ]
            )
        }
    }
}
    
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension Adapty.PluginDelegate: AdaptyPaywallControllerDelegate
{
    public func paywallController(_ controller: AdaptyPaywallController, didPerform action: AdaptyUI.Action)
    {
        invokeMethod(
            .paywallViewDidPerformAction,
            arguments: [
                .view: controller.toView(),
//                         .action: action,
            ]
        )
    }
        
    public func paywallController(
        _ controller: AdaptyPaywallController,
        didSelectProduct product: AdaptyPaywallProductWithoutDeterminingOffer
    )
    {
        invokeMethod(
            .paywallViewDidSelectProduct,
            arguments: [
                .view: controller.toView(),
//                         .product: product,
            ]
        )
    }
        
    public func paywallController(
        _ controller: AdaptyPaywallController,
        didStartPurchase product: AdaptyPaywallProduct
    )
    {
        invokeMethod(
            .paywallViewDidStartPurchase,
            arguments: [
                .view: controller.toView(),
//                         .product: product,
            ]
        )
    }
        
    public func paywallController(
        _ controller: AdaptyPaywallController,
        didCancelPurchase product: AdaptyPaywallProduct
    )
    {
        invokeMethod(
            .paywallViewDidCancelPurchase,
            arguments: [
                .view: controller.toView(),
//                         .product: product,
            ]
        )
    }
        
    public func paywallController(
        _ controller: AdaptyPaywallController,
        didFinishPurchase product: AdaptyPaywallProduct,
        purchaseResult: AdaptyPurchaseResult
    )
    {
        invokeMethod(
            .paywallViewDidFinishPurchase,
            arguments: [
                .view: controller.toView(),
//                         .product: product,
                .purchasedResult: purchaseResult,
            ]
        )
    }
        
    public func paywallController(
        _ controller: AdaptyPaywallController,
        didFailPurchase product: AdaptyPaywallProduct,
        error: AdaptyError
    )
    {
        invokeMethod(
            .paywallViewDidFailPurchase,
            arguments: [
                .view: controller.toView(),
//                         .product: product,
                .error: error,
            ]
        )
    }
        
    public func paywallControllerDidStartRestore(_ controller: AdaptyPaywallController)
    {
        invokeMethod(
            .paywallViewDidStartRestore,
            arguments: [
                .view: controller.toView(),
            ]
        )
    }
        
    public func paywallController(
        _ controller: AdaptyPaywallController,
        didFinishRestoreWith profile: AdaptyProfile
    )
    {
        invokeMethod(
            .paywallViewDidFinishRestore,
            arguments: [
                .view: controller.toView(),
                .profile: profile,
            ]
        )
    }
        
    public func paywallController(
        _ controller: AdaptyPaywallController,
        didFailRestoreWith error: AdaptyError
    )
    {
        invokeMethod(
            .paywallViewDidFailRestore,
            arguments: [
                .view: controller.toView(),
                .error: error,
            ]
        )
    }
        
    public func paywallController(
        _ controller: AdaptyPaywallController,
        didFailRenderingWith error: AdaptyError
    )
    {
        invokeMethod(
            .paywallViewDidFailRendering,
            arguments: [
                .view: controller.toView(),
                .error: error,
            ]
        )
    }
        
    public func paywallController(
        _ controller: AdaptyPaywallController,
        didFailLoadingProductsWith error: AdaptyError
    ) -> Bool
    {
        invokeMethod(
            .paywallViewDidFailLoadingProducts,
            arguments: [
                .view: controller.toView(),
                .error: error,
            ]
        )
            
        return true
    }
}
