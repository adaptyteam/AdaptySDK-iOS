//
//  StoreKit.Transaction.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.10.2023
//

import StoreKit

extension StoreKit.Transaction {
    func logParams(other: EventParameters?) -> EventParameters {
        guard let other else { return logParams }
        return logParams.merging(other) { _, new in new }
    }

    var logParams: EventParameters {
        [
            "product_id": productID,
            "transaction_is_upgraded": isUpgraded,
            "transaction_id": id,
            "original_id": originalID,
        ]
    }

    var unfBillingPlan: AdaptySubscriptionBillingPlan? {
        #if compiler(>=6.3.2)
        if #available(iOS 26.4, macOS 26.4, tvOS 26.4, watchOS 26.4, visionOS 26.4, *) {
            return billingPlanType?.asAdaptySubscriptionBillingPlan
        }
        #endif
        return nil
    }

    var unfOfferType: AdaptyTransactionOfferType? {
        if #available(iOS 17.2, macOS 14.2, tvOS 17.2, watchOS 10.2, visionOS 1.1, *) {
            offer?.type.asAdaptyTransactionOfferType
        } else {
            offerType?.asAdaptyTransactionOfferType
        }
    }

    var unfOfferId: String? {
        if #available(iOS 17.2, macOS 14.2, tvOS 17.2, watchOS 10.2, visionOS 1.1, *) {
            return offer?.id
        }
        return offerID
    }

    var isXcodeEnvironment: Bool {
        #if !os(visionOS)
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *) else {
            return environmentStringRepresentation.lowercased() == "xcode"
        }
        #endif

        return environment == .xcode
    }

    var unfEnvironment: String {
        #if !os(visionOS)
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *) else {
            let environment = environmentStringRepresentation
            return environment.lowercased()
        }
        #endif

        return switch environment {
        case .production: Self.productionEnvironment
        case .sandbox: Self.sandboxEnvironment
        case .xcode: Self.xcodeEnvironment
        default: environment.rawValue.lowercased()
        }
    }

    static let productionEnvironment = "production"
    static let sandboxEnvironment = "sandbox"
    static let xcodeEnvironment = "xcode"
}
