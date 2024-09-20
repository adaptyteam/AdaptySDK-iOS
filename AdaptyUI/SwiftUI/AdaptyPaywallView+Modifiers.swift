//
//  AdaptyPaywallView+Modifiers.swift
//  Adapty
//
//  Created by Aleksey Goncharov on 20.09.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, *)
enum Modifier {
    struct OnPaywallDidPerformAction: ViewModifier {
        private let callback: (AdaptyUI.Action) -> Void

        init(callback: @escaping (AdaptyUI.Action) -> Void) {
            self.callback = callback
        }

        func body(content: Content) -> some View {
            content
                .onPreferenceChange(PreferenceKeys.OnPaywallDidPerformAction.self) { action in
                    if let action {
                        self.callback(action)
                    }
                }
        }
    }

    struct OnPaywallDidSelectProduct: ViewModifier {
        private let callback: (AdaptyPaywallProduct) -> Void

        init(callback: @escaping (AdaptyPaywallProduct) -> Void) {
            self.callback = callback
        }

        func body(content: Content) -> some View {
            content
                .onPreferenceChange(PreferenceKeys.OnPaywallDidSelectProduct.self) { product in
                    if let product {
                        self.callback(product)
                    }
                }
        }
    }

    struct OnPaywallDidStartPurchase: ViewModifier {
        private let callback: (AdaptyPaywallProduct) -> Void

        init(callback: @escaping (AdaptyPaywallProduct) -> Void) {
            self.callback = callback
        }

        func body(content: Content) -> some View {
            content
                .onPreferenceChange(PreferenceKeys.OnPaywallDidStartPurchase.self) { product in
                    if let product {
                        self.callback(product)
                    }
                }
        }
    }

    struct OnPaywallDidFinishPurchase: ViewModifier {
        private let callback: (FinishPurchaseInfo) -> Void

        init(callback: @escaping (FinishPurchaseInfo) -> Void) {
            self.callback = callback
        }

        func body(content: Content) -> some View {
            content
                .onPreferenceChange(PreferenceKeys.OnPaywallDidFinishPurchase.self) { info in
                    if let info {
                        self.callback(info)
                    }
                }
        }
    }

    struct OnPaywallDidFailPurchase: ViewModifier {
        private let callback: (FailPurchaseInfo) -> Void

        init(callback: @escaping (FailPurchaseInfo) -> Void) {
            self.callback = callback
        }

        func body(content: Content) -> some View {
            content
                .onPreferenceChange(PreferenceKeys.OnPaywallDidFailPurchase.self) { info in
                    if let info {
                        self.callback(info)
                    }
                }
        }
    }

    struct OnPaywallDidCancelPurchase: ViewModifier {
        private let callback: (AdaptyPaywallProduct) -> Void

        init(callback: @escaping (AdaptyPaywallProduct) -> Void) {
            self.callback = callback
        }

        func body(content: Content) -> some View {
            content
                .onPreferenceChange(PreferenceKeys.OnPaywallDidCancelPurchase.self) { product in
                    if let product {
                        self.callback(product)
                    }
                }
        }
    }

    struct OnPaywallDidStartRestore: ViewModifier {
        private let callback: () -> Void

        init(callback: @escaping () -> Void) {
            self.callback = callback
        }

        func body(content: Content) -> some View {
            content
                .onPreferenceChange(PreferenceKeys.OnPaywallDidStartRestore.self) { started in
                    if started == true {
                        self.callback()
                    }
                }
        }
    }

    struct OnPaywallDidFinishRestore: ViewModifier {
        private let callback: (AdaptyProfile) -> Void

        init(callback: @escaping (AdaptyProfile) -> Void) {
            self.callback = callback
        }

        func body(content: Content) -> some View {
            content
                .onPreferenceChange(PreferenceKeys.OnPaywallDidFinishRestore.self) { profile in
                    if let profile {
                        self.callback(profile)
                    }
                }
        }
    }

    struct OnPaywallDidFailRestore: ViewModifier {
        private let callback: (AdaptyError) -> Void

        init(callback: @escaping (AdaptyError) -> Void) {
            self.callback = callback
        }

        func body(content: Content) -> some View {
            content
                .onPreferenceChange(PreferenceKeys.OnPaywallDidFailRestore.self) { error in
                    if let error {
                        self.callback(error)
                    }
                }
        }
    }

    struct OnPaywallDidFailRendering: ViewModifier {
        private let callback: (AdaptyError) -> Void

        init(callback: @escaping (AdaptyError) -> Void) {
            self.callback = callback
        }

        func body(content: Content) -> some View {
            content
                .onPreferenceChange(PreferenceKeys.OnPaywallDidFailRendering.self) { error in
                    if let error {
                        self.callback(error)
                    }
                }
        }
    }

    struct OnPaywallDidFailLoadingProducts: ViewModifier {
        private let callback: (AdaptyError) -> Void

        init(callback: @escaping (AdaptyError) -> Void) {
            self.callback = callback
        }

        func body(content: Content) -> some View {
            content
                .onPreferenceChange(PreferenceKeys.OnPaywallDidFailLoadingProducts.self) { error in
                    if let error {
                        self.callback(error)
                    }
                }
        }
    }
}

#endif
