//
//  Adapty+Combine.swift
//  Adapty
//
//  Created by Ilya Laryionau on 7.12.21.
//  Copyright © 2021 Adapty. All rights reserved.
//

#if canImport(Combine) && swift(>=5.0)
#if os(iOS) || targetEnvironment(macCatalyst)

import Combine

@available(swift 5.0)
@available(iOS 13.0, macCatalyst 13.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension Adapty {
    public static func updateAttribution(
        _ attribution: [AnyHashable: Any],
        source: AttributionNetwork,
        networkUserId: String? = nil,
        completion: ErrorCompletion? = nil
    ) -> Future<Void, AdaptyError> {
        Future<Void, AdaptyError> { promise in
            self.updateAttribution(
                attribution,
                source: source,
                networkUserId: networkUserId,
                completion: { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
            )
        }
    }

    public static func paywalls(
        forceUpdate: Bool = false
    ) -> Future<PaywallsResult, AdaptyError> {
        Future<PaywallsResult, AdaptyError> { promise in
            self.getPaywalls(forceUpdate: forceUpdate) { paywalls, products, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success((paywalls, products)))
                }
            }
        }
    }

    public static func purchase(
        _ product: ProductModel,
        offerId: String? = nil
    ) -> Future<PurchaseProductResult, AdaptyError> {
        Future<PurchaseProductResult, AdaptyError> { promise in
            self.makePurchase(
                product: product,
                offerId: offerId
            ) { purchaserInfo, receipt, appleValidationResult, product, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success((purchaserInfo, receipt, appleValidationResult, product)))
                }
            }
        }
    }

    public static func restorePurchases(
    ) -> Future<RestorePurchasesResult, AdaptyError> {
        Future<RestorePurchasesResult, AdaptyError> { promise in
            self.restorePurchases() { purchaserInfo, receipt, appleValidationResult, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success((purchaserInfo, receipt, appleValidationResult)))
                }
            }
        }
    }

    public static func validateReceipt(
        _ receiptEncoded: String
    ) -> Future<ValidateReceiptResult, AdaptyError> {
        Future<ValidateReceiptResult, AdaptyError> { promise in
            self.validateReceipt(receiptEncoded) { purchaserInfo, parameters, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success((purchaserInfo, parameters)))
                }
            }
        }
    }
}

#endif // os(iOS) || targetEnvironment(macCatalyst)
#endif // canImport(Combine) && swift(>=5.0)
