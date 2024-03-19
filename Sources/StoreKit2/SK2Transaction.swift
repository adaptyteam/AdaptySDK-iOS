//
//  SK2Transaction.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.10.2023
//

import StoreKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
typealias SK2Transaction = Transaction

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension SK2Transaction: AdaptyExtended {}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyExtension where Extended == SK2Transaction {
    var identifier: String {
        String(this.id)
    }

    var originalIdentifier: String {
        String(this.originalID)
    }

    var logParams: EventParameters {
        [
            "product_id": .value(this.productID),
            "transaction_is_upgraded": .value(this.isUpgraded),
            "transaction_id": .value(identifier),
            "original_id": .value(originalIdentifier),
        ]
    }

    var offerType: SK2Transaction.OfferType? {
        #if swift(>=5.9.2) && (!os(visionOS) || swift(>=5.10))
            if #available(iOS 17.2, macOS 14.2, tvOS 17.2, watchOS 10.2, visionOS 1.1, *) {
                return this.offer?.type
            }
        #endif
        return this.offerType
    }

    var offerId: String? {
        #if swift(>=5.9.2) && (!os(visionOS) || swift(>=5.10))
            if #available(iOS 17.2, macOS 14.2, tvOS 17.2, watchOS 10.2, visionOS 1.1, *) {
                return this.offer?.id
            }
        #endif
        return this.offerID
    }

    var environment: String {
        #if !os(visionOS)
            guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *) else {
                let environment = this.environmentStringRepresentation
                return environment.isEmpty ? "storekit2" : environment.lowercased()
            }
        #endif

        switch this.environment {
        case .production: return "production"
        case .sandbox: return "sandbox"
        case .xcode: return "xcode"
        default: return this.environment.rawValue
        }
    }
}
