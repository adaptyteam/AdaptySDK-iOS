//
//  File.swift
//  Adapty
//
//  Created by Aleksey Goncharov on 13.11.2024.
//


#if canImport(UIKit)

import Adapty
import UIKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyUI {
    @MainActor
    public class PluginDelegate: NSObject, AdaptyPaywallControllerDelegate {
        public static let shared = PluginDelegate()
        public weak var proxyDelegate: AdaptyPaywallControllerDelegate?
        
        //    let channel: FlutterMethodChannel
        //
        //    init(channel: FlutterMethodChannel) {
        //        self.channel = channel
        //    }
        //
        //    private func invokeMethod(_ methodName: MethodName, arguments: [ArgumentName: Encodable]) {
        //        do {
        //            var args = [String: String]()
        //
        //            for (arg, model) in arguments {
        //                args[arg.rawValue] = try encodeModelToString(model)
        //            }
        //
        //            channel.invokeMethod(methodName.rawValue, arguments: args)
        //        } catch {
        //            AdaptyUI.writeLog(level: .error,
        //                              message: "Plugin encoding error: \(error.localizedDescription)")
        //        }
        //    }
        
        public func paywallController(_ controller: AdaptyPaywallController, didPerform action: AdaptyUI.Action) {
            //        invokeMethod(.paywallViewDidPerformAction,
            //                     arguments: [
            //                         .view: controller.toView(),
            //                         .action: action.codableAction,
            //                     ])
        }
        
        public func paywallController(_ controller: AdaptyPaywallController,
                                      didSelectProduct product: AdaptyPaywallProduct)
        {
//            invokeMethod(.paywallViewDidSelectProduct,
//                         arguments: [
//                            .view: controller.toView(),
//                            .product: product,
//                         ])
        }
        
        public func paywallController(_ controller: AdaptyPaywallController,
                                      didStartPurchase product: AdaptyPaywallProduct)
        {
//            invokeMethod(.paywallViewDidStartPurchase,
//                         arguments: [
//                            .view: controller.toView(),
//                            .product: product,
//                         ])
        }
        
        public func paywallController(_ controller: AdaptyPaywallController,
                                      didCancelPurchase product: AdaptyPaywallProduct)
        {
//            invokeMethod(.paywallViewDidCancelPurchase,
//                         arguments: [
//                            .view: controller.toView(),
//                            .product: product,
//                         ])
        }
        
        public func paywallController(_ controller: AdaptyPaywallController,
                                      didFinishPurchase product: AdaptyPaywallProduct,
                                      purchaseResult: AdaptyPurchaseResult)
        {
//            invokeMethod(.paywallViewDidFinishPurchase,
//                         arguments: [
//                            .view: controller.toView(),
//                            .product: product,
//                            .profile: purchasedInfo.profile,
//                         ])
        }
        
        public func paywallController(_ controller: AdaptyPaywallController,
                                      didFailPurchase product: AdaptyPaywallProduct,
                                      error: AdaptyError)
        {
//            invokeMethod(.paywallViewDidFailPurchase,
//                         arguments: [
//                            .view: controller.toView(),
//                            .product: product,
//                            .error: error,
//                         ])
        }
        
        public func paywallControllerDidStartRestore(_ controller: AdaptyPaywallController) {
//            invokeMethod(.paywallViewDidStartRestore,
//                         arguments: [
//                            .view: controller.toView(),
//                         ])
        }
        
        public func paywallController(_ controller: AdaptyPaywallController,
                                      didFinishRestoreWith profile: AdaptyProfile)
        {
//            invokeMethod(.paywallViewDidFinishRestore,
//                         arguments: [
//                            .view: controller.toView(),
//                            .profile: profile,
//                         ])
        }
        
        public func paywallController(_ controller: AdaptyPaywallController,
                                      didFailRestoreWith error: AdaptyError)
        {
//            invokeMethod(.paywallViewDidFailRestore,
//                         arguments: [
//                            .view: controller.toView(),
//                            .error: error,
//                         ])
        }
        
        public func paywallController(_ controller: AdaptyPaywallController,
                                      didFailRenderingWith error: AdaptyError)
        {
//            invokeMethod(.paywallViewDidFailRendering,
//                         arguments: [
//                            .view: controller.toView(),
//                            .error: error,
//                         ])
        }
        
        public func paywallController(_ controller: AdaptyPaywallController,
                                      didFailLoadingProductsWith error: AdaptyError) -> Bool
        {
//            invokeMethod(.paywallViewDidFailLoadingProducts,
//                         arguments: [
//                            .view: controller.toView(),
//                            .error: error,
//                         ])
            
            return true
        }
    }
}

#endif
