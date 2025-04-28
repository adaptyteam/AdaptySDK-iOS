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
extension SK2Transaction {
    @inlinable
    var unfIdentifier: String { String(id) }

    @inlinable
    var unfOriginalIdentifier: String { String(originalID) }

    @inlinable
    var unfProductID: String { productID }

    var logParams: EventParameters {
        [
            "product_id": unfProductID,
            "transaction_is_upgraded": isUpgraded,
            "transaction_id": unfIdentifier,
            "original_id": unfOriginalIdentifier,
        ]
    }

    var unfOfferType: SK2Transaction.OfferType? {
        #if compiler(>=5.9.2) && (!os(visionOS) || compiler(>=5.10))
            if #available(iOS 17.2, macOS 14.2, tvOS 17.2, watchOS 10.2, visionOS 1.1, *) {
                return offer?.type
            }
        #endif
        return offerType
    }

    var unfOfferId: String? {
        #if compiler(>=5.9.2) && (!os(visionOS) || compiler(>=5.10))
            if #available(iOS 17.2, macOS 14.2, tvOS 17.2, watchOS 10.2, visionOS 1.1, *) {
                return offer?.id
            }
        #endif
        return offerID
    }

    var unfEnvironment: String {
        #if !os(visionOS)
            guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *) else {
                let environment = environmentStringRepresentation
                return environment.isEmpty ? "storekit2" : environment.lowercased()
            }
        #endif

        switch environment {
        case .production: return "production"
        case .sandbox: return "sandbox"
        case .xcode: return "xcode"
        default: return environment.rawValue
        }
    }
}
