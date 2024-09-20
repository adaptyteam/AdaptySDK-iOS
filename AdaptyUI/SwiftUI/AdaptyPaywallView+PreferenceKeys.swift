//
//  AdaptyPaywallView+PreferenceKeys.swift
//  Adapty
//
//  Created by Aleksey Goncharov on 20.09.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, *)
enum PreferenceKeys {
    struct OnPaywallDidPerformAction: PreferenceKey {
        static var defaultValue: AdaptyUI.Action?

        static func reduce(value: inout AdaptyUI.Action?, nextValue: () -> AdaptyUI.Action?) {
            value = nextValue()
        }
    }

    struct OnPaywallDidSelectProduct: PreferenceKey {
        static var defaultValue: AdaptyPaywallProduct?
        static func reduce(value: inout AdaptyPaywallProduct?, nextValue: () -> AdaptyPaywallProduct?) {
            value = nextValue()
        }
    }

    struct OnPaywallDidStartPurchase: PreferenceKey {
        static var defaultValue: AdaptyPaywallProduct?
        static func reduce(value: inout AdaptyPaywallProduct?, nextValue: () -> AdaptyPaywallProduct?) {
            value = nextValue()
        }
    }

    struct OnPaywallDidFinishPurchase: PreferenceKey {
        static var defaultValue: FinishPurchaseInfo?
        static func reduce(value: inout FinishPurchaseInfo?, nextValue: () -> FinishPurchaseInfo?) {
            value = nextValue()
        }
    }

    struct OnPaywallDidFailPurchase: PreferenceKey {
        static var defaultValue: FailPurchaseInfo?
        static func reduce(value: inout FailPurchaseInfo?, nextValue: () -> FailPurchaseInfo?) {
            value = nextValue()
        }
    }

    struct OnPaywallDidCancelPurchase: PreferenceKey {
        static var defaultValue: AdaptyPaywallProduct?
        static func reduce(value: inout AdaptyPaywallProduct?, nextValue: () -> AdaptyPaywallProduct?) {
            value = nextValue()
        }
    }

    struct OnPaywallDidStartRestore: PreferenceKey {
        static var defaultValue: Bool?
        static func reduce(value: inout Bool?, nextValue: () -> Bool?) {
            value = nextValue()
        }
    }

    struct OnPaywallDidFinishRestore: PreferenceKey {
        static var defaultValue: AdaptyProfile?
        static func reduce(value: inout AdaptyProfile?, nextValue: () -> AdaptyProfile?) {
            value = nextValue()
        }
    }

    struct OnPaywallDidFailRestore: PreferenceKey {
        static var defaultValue: AdaptyError?
        static func reduce(value: inout AdaptyError?, nextValue: () -> AdaptyError?) {
            value = nextValue()
        }
    }

    struct OnPaywallDidFailRendering: PreferenceKey {
        static var defaultValue: AdaptyError?
        static func reduce(value: inout AdaptyError?, nextValue: () -> AdaptyError?) {
            value = nextValue()
        }
    }

    struct OnPaywallDidFailLoadingProducts: PreferenceKey {
        static var defaultValue: AdaptyError?
        static func reduce(value: inout AdaptyError?, nextValue: () -> AdaptyError?) {
            value = nextValue()
        }
    }
}

#endif
