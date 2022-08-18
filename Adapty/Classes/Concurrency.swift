//
//  Concurrency.swift
//  Adapty
//
//  Copyright © 2022 Adapty. All rights reserved.
//

extension Adapty {
    public typealias MakePurchaseResult = (
        purchaserInfo: PurchaserInfoModel?,
        receipt: String?,
        appleValidationResult: Parameters?,
        product: ProductModel?
    )

    public typealias RestorePurchasesResult = (
        purchaserInfo: PurchaserInfoModel?,
        receipt: String?,
        appleValidationResult: Parameters?
    )

    public typealias SyncTransactionsHistoryResult = (
        parameters: Parameters?,
        products: [ProductModel]?
    )
}

#if canImport(_Concurrency) && compiler(>=5.5.2)
    @available(macOS 10.15, iOS 13.0.0, watchOS 6.0, tvOS 13.0, *)
    extension Adapty {
        public static func activate(_ apiKey: String, observerMode: Bool, customerUserId: String?) async throws {
            return try await withCheckedThrowingContinuation { continuation in
                Adapty.activate(apiKey, observerMode: observerMode, customerUserId: customerUserId) { error in
                    if let error = error {
                        return continuation.resume(throwing: error)
                    }
                    continuation.resume(
                        returning: ()
                    )
                }
            }
        }

        public static func identify(_ customerUserId: String) async throws {
            return try await withCheckedThrowingContinuation { continuation in
                Adapty.identify(customerUserId) { error in
                    if let error = error {
                        return continuation.resume(throwing: error)
                    }
                    continuation.resume(
                        returning: ()
                    )
                }
            }
        }

        public static func updateProfile(params: ProfileParameterBuilder) async throws {
            return try await withCheckedThrowingContinuation { continuation in
                Adapty.updateProfile(params: params) { error in
                    if let error = error {
                        return continuation.resume(throwing: error)
                    }
                    continuation.resume(
                        returning: ()
                    )
                }
            }
        }

        public static func updateAttribution(
            _ attribution: [AnyHashable: Any],
            source: AttributionNetwork,
            networkUserId: String? = nil
        ) async throws {
            return try await withCheckedThrowingContinuation { continuation in
                Adapty.updateAttribution(attribution, source: source, networkUserId: networkUserId) { error in
                    if let error = error {
                        return continuation.resume(throwing: error)
                    }
                    continuation.resume(
                        returning: ()
                    )
                }
            }
        }

        public static func getPaywall(_ id: String, forceUpdate: Bool = false) async throws -> PaywallModel? {
            return try await withCheckedThrowingContinuation { continuation in
                Adapty.getPaywall(id, forceUpdate: forceUpdate) { paywall, error in
                    if let error = error {
                        return continuation.resume(throwing: error)
                    }
                    continuation.resume(
                        returning: paywall
                    )
                }
            }
        }

        public static func getProducts(forceUpdate: Bool = false) async throws -> [ProductModel]? {
            return try await withCheckedThrowingContinuation { continuation in
                Adapty.getProducts(forceUpdate: forceUpdate) { products, error in
                    if let error = error {
                        return continuation.resume(throwing: error)
                    }
                    continuation.resume(
                        returning: products
                    )
                }
            }
        }

        public static func makePurchase(
            product: ProductModel,
            offerID: String? = nil
        ) async throws -> MakePurchaseResult {
            return try await withCheckedThrowingContinuation { continuation in
                Adapty.makePurchase(
                    product: product,
                    offerId: offerID,
                    completion: { purchaserInfo, receipt, appleValidationResult, product, error in
                        if let error = error {
                            return continuation.resume(throwing: error)
                        }
                        continuation.resume(
                            returning: (purchaserInfo, receipt, appleValidationResult, product)
                        )
                    }
                )
            }
        }

        public static func restorePurchases() async throws -> RestorePurchasesResult {
            return try await withCheckedThrowingContinuation { continuation in
                Adapty.restorePurchases { purchaserInfo, receipt, appleValidationResult, error in
                    if let error = error {
                        return continuation.resume(throwing: error)
                    }
                    continuation.resume(
                        returning: (purchaserInfo, receipt, appleValidationResult)
                    )
                }
            }
        }

        public static func syncTransactionsHistory() async throws -> SyncTransactionsHistoryResult {
            return try await withCheckedThrowingContinuation { continuation in
                Adapty.syncTransactionsHistory { parameters, products, error in
                    if let error = error {
                        return continuation.resume(throwing: error)
                    }
                    continuation.resume(
                        returning: (parameters, products)
                    )
                }
            }
        }

        public static func getPurchaserInfo(forceUpdate: Bool = false) async throws -> PurchaserInfoModel? {
            return try await withCheckedThrowingContinuation { continuation in
                Adapty.getPurchaserInfo(forceUpdate: forceUpdate) { purchaserInfo, error in
                    if let error = error {
                        return continuation.resume(throwing: error)
                    }
                    continuation.resume(
                        returning: purchaserInfo
                    )
                }
            }
        }

    public static func setFallbackPaywalls(_ paywalls: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            Adapty.setFallbackPaywalls(paywalls) { error in
                if let error = error {
                    return continuation.resume(throwing: error)
                }
                continuation.resume(
                    returning: ()
                )
            }
        }
    }

        public static func logShowPaywall(_ paywall: PaywallModel) async throws {
            return try await withCheckedThrowingContinuation { continuation in
                Adapty.logShowPaywall(paywall) { error in
                    if let error = error {
                        return continuation.resume(throwing: error)
                    }
                    continuation.resume(
                        returning: ()
                    )
                }
            }
        }

        public static func setExternalAnalyticsEnabled(_ enabled: Bool) async throws {
            return try await withCheckedThrowingContinuation { continuation in
                Adapty.setExternalAnalyticsEnabled(enabled) { error in
                    if let error = error {
                        return continuation.resume(throwing: error)
                    }
                    continuation.resume(
                        returning: ()
                    )
                }
            }
        }

        public static func setVariationId(
            _ variationId: String,
            forTransactionId transactionId: String
        ) async throws {
            return try await withCheckedThrowingContinuation { continuation in
                Adapty.setVariationId(variationId, forTransactionId: transactionId) { error in
                    if let error = error {
                        return continuation.resume(throwing: error)
                    }
                    continuation.resume(
                        returning: ()
                    )
                }
            }
        }

        public static func logout() async throws {
            return try await withCheckedThrowingContinuation { continuation in
                Adapty.logout { error in
                    if let error = error {
                        return continuation.resume(throwing: error)
                    }
                    continuation.resume(
                        returning: ()
                    )
                }
            }
        }
    }
#endif
