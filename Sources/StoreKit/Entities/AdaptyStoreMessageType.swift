//
//  AdaptyStoreMessageType.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 17.08.2026.
//

import StoreKit

/// A stable, platform-neutral category of an App Store message waiting to be displayed.
public struct AdaptyStoreMessageType: RawRepresentable, Sendable, Hashable {
    public let rawValue: String

    /// Creates a message type from its stable raw value.
    ///
    /// - Parameter rawValue: A known Adapty value or an opaque provider-specific value.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// A general App Store message.
    public static let generic = Self(rawValue: "generic")

    /// A message requesting consent to a subscription price increase.
    public static let priceIncreaseConsent = Self(rawValue: "price_increase_consent")

    /// A message describing a subscription billing issue.
    public static let billingIssue = Self(rawValue: "billing_issue")

    /// A message presenting an eligible win-back offer.
    public static let winBackOffer = Self(rawValue: "win_back_offer")
}

#if os(iOS) || os(visionOS)

@available(iOS 16.0, macCatalyst 16.0, visionOS 1.0, *)
extension AdaptyStoreMessageType {
    init(_ reason: StoreKit.Message.Reason) {
        if reason == .generic {
            self = .generic
        } else if reason == .priceIncreaseConsent {
            self = .priceIncreaseConsent
        } else if #available(iOS 16.4, macCatalyst 16.4, visionOS 1.0, *), reason == .billingIssue {
            self = .billingIssue
        } else if #available(iOS 18.0, macCatalyst 18.0, visionOS 2.0, *), reason == .winBackOffer {
            self = .winBackOffer
        } else {
            self.init(rawValue: "storekit_\(reason.rawValue)")
        }
    }
}

#endif
