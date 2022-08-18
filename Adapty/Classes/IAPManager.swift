//
//  IAPManager.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 12/12/2019.
//

import Foundation
import StoreKit

public typealias BuyProductCompletion = (_ purchaserInfo: PurchaserInfoModel?, _ receipt: String?, _ appleValidationResult: Parameters?, _ product: ProductModel?, _ error: AdaptyError?) -> Void
public typealias RestorePurchasesCompletion = (_ purchaserInfo: PurchaserInfoModel?, _ receipt: String?, _ appleValidationResult: Parameters?, _ error: AdaptyError?) -> Void
public typealias DeferredPurchaseCompletion = (BuyProductCompletion?) -> Void
private typealias RefreshReceiptCompletion = (_ receipt: String?) -> Void
private typealias PurchaseInfoTuple = (product: ProductModel, payment: SKPayment, completion: BuyProductCompletion?)

class IAPManager: NSObject {
    private var profileId: String {
        DefaultsManager.shared.profileId
    }

    private(set) var storedPaywalls = DefaultsManager.shared.cachedPaywalls {
        didSet {
            DefaultsManager.shared.cachedPaywalls = storedPaywalls
        }
    }

    private(set) var storedProducts = DefaultsManager.shared.cachedProducts ?? [] {
        didSet {
            DefaultsManager.shared.cachedProducts = storedProducts
        }
    }

    private var cachedVariationsIds: [String: String] {
        get {
            return DefaultsManager.shared.cachedVariationsIds
        }
        set {
            DefaultsManager.shared.cachedVariationsIds = newValue
        }
    }

    private var skProductsRequest: (task: SKProductsRequest, products: [ProductModel])?
    private var allProductsRequest: URLSessionDataTask?
    private var allProductsRequestCompletions: [ProductsCompletion] = []

    private var refreshReceiptCompletions: [RefreshReceiptCompletion] = []
    private var refreshReceiptRequest: SKReceiptRefreshRequest?

    private var isSyncedAtLeastOnce: Bool = false

    private var productsToBuy: [PurchaseInfoTuple] = []

    private var totalRestoredPurchases = 0
    private var restorePurchasesCompletion: RestorePurchasesCompletion?

    private var apiManager: ApiManager

    // MARK: - Public

    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }

    func startObservingPurchases(syncTransactions: Bool, _ completion: ProductsCompletion? = nil) {
        startObserving()

        if syncTransactions {
            syncTransactionsHistory { _, products, error in
                completion?(products, error)
            }
        } else {
            internalGetAllProducts(forceUpdate: false, completion)
        }

        NotificationCenter.default.addObserver(forName: Application.willTerminateNotification, object: nil, queue: .main) { [weak self] _ in
            self?.stopObserving()
        }
    }

    func getPaywall(_ id: String, forceUpdate: Bool = false, _ completion: @escaping PaywallCompletion) {
        getProducts(forceUpdate: false) { [weak self] _, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let self = self else {
                completion(nil, nil)
                return
            }
            
            self.internalGetPaywall(id, forceUpdate: forceUpdate, completion)
        }
    }
    
    private func internalGetPaywall(_ id: String, forceUpdate: Bool = false, _ completion: @escaping PaywallCompletion) {
        func updateSKProducts(_ paywall: PaywallModel, _ completion: @escaping PaywallCompletion) {
            let products = storedProducts
            guard !products.isEmpty else {
                completion(paywall, nil)
                return
            }
            paywall.products.forEach {
                let vendorProductId = $0.vendorProductId
                if let skProduct = products.first { $0.vendorProductId == vendorProductId }?.skProduct {
                    $0.skProduct = skProduct
                }
            }
            completion(paywall, nil)
        }

        if !forceUpdate, let paywall = storedPaywalls[id] {
            // call callback instantly with freshly cached data if there are such
            DispatchQueue.main.async {
                updateSKProducts(paywall, completion)
            }
        } else {
            apiManager.getPaywall(id: id, params: ["profile_id": profileId]) { paywall, error in

                if let error = error {
                    completion(nil, error)
                    return
                }
                guard let paywall = paywall else {
                    completion(nil, nil)
                    return
                }

                var paywalls = self.storedPaywalls
                paywalls[paywall.developerId] = paywall
                self.storedPaywalls = paywalls

                updateSKProducts(paywall, completion)
            }
        }
    }

    func getProducts(forceUpdate: Bool = false, _ completion: @escaping ProductsCompletion) {
        if !forceUpdate, !storedProducts.isEmpty, isSyncedAtLeastOnce {
            // call callback instantly with freshly cached data if there are such
            DispatchQueue.main.async {
                completion(self.storedProducts, nil)
            }
        } else {
            // sync paywalls and return data in case of missing cached data
            internalGetAllProducts(forceUpdate: false, completion)
        }
    }

    private func internalGetAllProducts(forceUpdate: Bool, _ completion: ProductsCompletion? = nil) {
        if let completion = completion {
            allProductsRequestCompletions.append(completion)
        }

        // syncing already in progress
        if allProductsRequest != nil && forceUpdate == false {
            return
        }

        allProductsRequest = apiManager.getProducts(params: ["profile_id": profileId]) { products, error in

            guard let error = error else {
                self.requestSKProducts(products)
                return
            }

            let products = self.storedProducts
            if products.isEmpty {
                // request products with cached data
                self.requestSKProducts(products)
            } else {
                self.callProductsCompletionAndCleanCallback(.failure(error))
            }
        }
    }

    func setFallbackPaywalls(_ paywalls: String, completion: ErrorCompletion? = nil) {
        // either already have cached paywalls or appstore request is in progress, which means real paywalls were successfully received
        if !storedPaywalls.isEmpty || skProductsRequest != nil {
            LoggerManager.logMessage("Tried to set Fallback Paywalls but it's unnecessary, since we already have a real paywalls data.")
            handleSetFallbackPaywallsError(nil, completion: completion)
            return
        }

        var fallbackPaywalls: FallbackPaywalls?
        do {
            guard
                let paywallsData = paywalls.data(using: .utf8),
                let paywallsJSON = try JSONSerialization.jsonObject(with: paywallsData, options: []) as? Parameters
            else {
                handleSetFallbackPaywallsError(AdaptyError.unableToDecode, completion: completion)
                return
            }

            fallbackPaywalls = try FallbackPaywalls(json: paywallsJSON)
        } catch let error as AdaptyError {
            handleSetFallbackPaywallsError(error, completion: completion)
            return
        } catch {
            handleSetFallbackPaywallsError(AdaptyError(with: error), completion: completion)
            return
        }

        allProductsRequestCompletions.append { [weak self] _, error in
            self?.handleSetFallbackPaywallsError(error, completion: completion)
        }

        if storedPaywalls.isEmpty, let paywalls = fallbackPaywalls?.paywalls, !paywalls.isEmpty {
            storedPaywalls = paywalls
        }
        requestSKProducts(fallbackPaywalls?.products)
    }

    private func handleSetFallbackPaywallsError(_ error: AdaptyError?, completion: ErrorCompletion? = nil) {
        DispatchQueue.main.async {
            completion?(error)
        }
    }

    private func requestSKProducts(_ products: [ProductModel]?) {
        skProductsRequest?.task.cancel()
        guard let products = products, !products.isEmpty else {
            callProductsCompletionAndCleanCallback(.failure(AdaptyError.noProductIDsFound))
            return
        }

        skProductsRequest = (
            task: SKProductsRequest(productIdentifiers: Set(products.map { $0.vendorProductId })),
            products: products
        )
        skProductsRequest?.task.delegate = self
        skProductsRequest?.task.start()
    }

    private func startObserving() {
        SKPaymentQueue.default().add(self)
    }

    private func stopObserving() {
        SKPaymentQueue.default().remove(self)
    }

    private var canMakePayments: Bool {
        SKPaymentQueue.canMakePayments()
    }

    func makePurchase(product: ProductModel, offerId: String? = nil, completion: BuyProductCompletion? = nil) {
        guard canMakePayments else {
            DispatchQueue.main.async {
                completion?(nil, nil, nil, product, AdaptyError.cantMakePayments)
            }
            return
        }

        // try to fill SKProduct for cached product
        product.skProduct = skProduct(for: product)
        if product.skProduct != nil {
            // procceed to payment in case of a valid SKProduct
            internalMakePurchase(product: product, offerId: offerId, completion: completion)
            return
        }

        // re-sync products to get an actual data
        internalGetAllProducts(forceUpdate: false) { _, _ in
            product.skProduct = self.skProduct(for: product)
            self.internalMakePurchase(product: product, offerId: offerId, completion: completion)
        }
    }

    private func internalMakePurchase(product: ProductModel, offerId: String? = nil, completion: BuyProductCompletion? = nil) {
        guard let skProduct = product.skProduct else {
            DispatchQueue.main.async {
                completion?(nil, nil, nil, product, AdaptyError.noProductsFound)
            }
            return
        }

        if #available(iOS 12.2, macOS 10.14.4, *), let offerId = offerId {
            createPayment(from: product, discountId: offerId, skProduct: skProduct, completion: completion)
        } else {
            createPayment(from: product, skProduct: skProduct, completion: completion)
        }
    }

    func restorePurchases(_ completion: RestorePurchasesCompletion? = nil) {
        restorePurchasesCompletion = completion
        totalRestoredPurchases = 0
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    var latestReceipt: String? {
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL, FileManager.default.fileExists(atPath: appStoreReceiptURL.path) else {
            return nil
        }

        var receiptData: Data?
        do {
            receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
        } catch {
            LoggerManager.logError("Couldn't read receipt data.\n\(error)")
        }

        guard let receipt = receiptData?.base64EncodedString(options: []) else {
            LoggerManager.logError(AdaptyError.cantReadReceipt)
            return nil
        }

        return receipt
    }

    func syncTransactionsHistory(completion: SyncTransactionsHistoryCompletion? = nil) {
        func getProducts(with validationResult: Parameters?) {
            internalGetAllProducts(forceUpdate: true) { products, paywallsError in
                completion?(validationResult, products, paywallsError)
            }
        }

        func validate(receipt: String) {
            Adapty.validateReceipt(receipt) { _, validationResult, _ in
                // re-sync paywalls so user'll get updated eligibility properties
                getProducts(with: validationResult)
            }
        }

        getReceipt { receipt in
            if let receipt = receipt {
                validate(receipt: receipt)
            } else {
                getProducts(with: nil)
            }
        }
    }

    private func createPayment(from product: ProductModel, skProduct: SKProduct, completion: BuyProductCompletion? = nil) {
        let payment = SKPayment(product: skProduct)

        productsToBuy.append((product: product,
                              payment: payment,
                              completion: completion))
        cachedVariationsIds[product.vendorProductId] = product.variationId

        SKPaymentQueue.default().add(payment)
    }

    @available(iOS 12.2, macOS 10.14.4, *)
    private func createPayment(from product: ProductModel, discountId: String, skProduct: SKProduct, completion: BuyProductCompletion? = nil) {
        apiManager.signSubscriptionOffer(params: ["product": product.vendorProductId, "offer_code": discountId, "profile_id": profileId]) { params, error in
            guard error == nil else {
                completion?(nil, nil, nil, product, error)
                return
            }

            guard
                let keyIdentifier = params?["key_id"] as? String,
                let nonceString = params?["nonce"] as? String,
                let nonce = UUID(uuidString: nonceString),
                let signature = params?["signature"] as? String,
                let timestampString = params?["timestamp"] as? String,
                let timestampInt64 = Int64(timestampString)
            else {
                completion?(nil, nil, nil, product, AdaptyError.missingOfferSigningParams)
                return
            }

            let timestamp = NSNumber(value: timestampInt64)
            let payment = SKMutablePayment(product: skProduct)
            payment.applicationUsername = ""
            payment.paymentDiscount = SKPaymentDiscount(identifier: discountId, keyIdentifier: keyIdentifier, nonce: nonce, signature: signature, timestamp: timestamp)

            self.productsToBuy.append((product: product,
                                       payment: payment,
                                       completion: completion))
            self.cachedVariationsIds[product.vendorProductId] = product.variationId

            SKPaymentQueue.default().add(payment)
        }
    }

    func presentCodeRedemptionSheet() {
        #if swift(>=5.3) && os(iOS) && !targetEnvironment(macCatalyst)
            if #available(iOS 14.0, *) {
                SKPaymentQueue.default().presentCodeRedemptionSheet()
            } else {
                LoggerManager.logError("Presenting code redemption sheet is available only for iOS 14 and higher.")
            }
        #endif
    }
}

private extension IAPManager {
    // MARK: - Refresh receipt

    private func getReceipt(completion: @escaping RefreshReceiptCompletion) {
        if let receipt = latestReceipt {
            completion(receipt)
        } else {
            refreshReceipt(completion: completion)
        }
    }

    private func refreshReceipt(completion: @escaping RefreshReceiptCompletion) {
        refreshReceiptCompletions.append(completion)
        if refreshReceiptRequest == nil {
            refreshReceiptRequest = SKReceiptRefreshRequest()
            refreshReceiptRequest?.delegate = self
            refreshReceiptRequest?.start()
        }
    }
}

private extension IAPManager {
    // MARK: - Callbacks handling

    private func callProductsCompletionAndCleanCallback(_ result: Result<[ProductModel], AdaptyError>) {
        DispatchQueue.main.async {
            switch result {
            case let .success(products):
                LoggerManager.logMessage("Successfully loaded list of products: [\(products.map { $0.vendorProductId }.joined(separator: ","))]")
                self.allProductsRequestCompletions.forEach { completion in
                    completion(products, nil)
                }
            case let .failure(error):
                LoggerManager.logError("Failed to load list of products.\n\(error.localizedDescription)")
                self.allProductsRequestCompletions.forEach { completion in
                    completion(nil, error)
                }
            }

            self.allProductsRequest = nil
            self.skProductsRequest = nil
            self.allProductsRequestCompletions.removeAll()
        }
    }

    private func callBuyProductCompletionAndCleanCallback(for purchaseInfo: PurchaseInfoTuple?, result: Result<(purchaserInfo: PurchaserInfoModel?, receipt: String, response: Parameters?), AdaptyError>) {
        DispatchQueue.main.async {
            // additional logs for success / error were moved to higher level because of the multiple calls in parent methods
            switch result {
            case let .success(result):
                purchaseInfo?.completion?(result.purchaserInfo, result.receipt, result.response, purchaseInfo?.product, nil)
            case let .failure(error):
                purchaseInfo?.completion?(nil, nil, nil, purchaseInfo?.product, error)
            }

            if let purchaseInfo = purchaseInfo {
                self.productsToBuy.removeAll { $0.product == purchaseInfo.product && $0.payment == purchaseInfo.payment }
            }
        }
    }

    private func callRestoreCompletionAndCleanCallback(_ result: Result<(purchaserInfo: PurchaserInfoModel?, receipt: String, response: Parameters?), AdaptyError>) {
        DispatchQueue.main.async {
            switch result {
            case let .success(result):
                LoggerManager.logMessage("Successfully restored purchases.")
                self.restorePurchasesCompletion?(result.purchaserInfo, result.receipt, result.response, nil)
            case let .failure(error):
                LoggerManager.logError("Failed to restore purchases.\n\(error.localizedDescription)")
                self.restorePurchasesCompletion?(nil, nil, nil, error)
            }

            self.restorePurchasesCompletion = nil
        }
    }
}

extension IAPManager: SKProductsRequestDelegate {
    // MARK: - Products list and refresh receipt

    func requestDidFinish(_ request: SKRequest) {
        guard let request = request as? SKReceiptRefreshRequest else { return }
        refreshReceiptRequest = nil
        refreshReceiptCompletions.forEach({ $0(latestReceipt) })
        refreshReceiptCompletions.removeAll()
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        for product in response.products {
            LoggerManager.logMessage("Found product: \(product.productIdentifier) \(product.localizedTitle) \(product.price.floatValue)")
        }

        isSyncedAtLeastOnce = true

        guard var products = skProductsRequest?.products, !products.isEmpty, !response.products.isEmpty else {
            callProductsCompletionAndCleanCallback(.failure(AdaptyError.noProductsFound))
            return
        }

        response.products.forEach { skProduct in
            products
                .filter { $0.vendorProductId == skProduct.productIdentifier }
                .forEach { product in
                    product.skProduct = skProduct
                }
        }

        storedProducts = products
        callProductsCompletionAndCleanCallback(.success(products))
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        if let request = request as? SKReceiptRefreshRequest {
            refreshReceiptRequest = nil
            refreshReceiptCompletions.forEach({ $0(nil) })
            refreshReceiptCompletions.removeAll()
            return
        }

        if #available(iOS 14.0, *), let error = error as? SKError, SKError.Code(rawValue: error.errorCode) == SKError.unknown {
            LoggerManager.logError("Can't fetch products from Store. Please, make sure you run simulator under iOS 14 or if you want to continue using iOS 14 make sure you run it on a real device.")
        }

        callProductsCompletionAndCleanCallback(.failure(AdaptyError(with: error)))
    }
}

extension IAPManager: SKPaymentTransactionObserver {
    // MARK: - Transactions

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { transaction in
            switch transaction.transactionState {
            case .purchased:
                purchased(transaction)

            case .failed:
                failed(transaction)

            case .restored:
                restored(transaction)

            case .deferred, .purchasing: break
            @unknown default: break
            }
        }
    }

    private func purchaseInfo(for transaction: SKPaymentTransaction) -> PurchaseInfoTuple? {
        return productsToBuy.filter({ $0.payment.productIdentifier == transaction.payment.productIdentifier }).first
    }

    private func product(for transaction: SKPaymentTransaction) -> ProductModel? {
        return storedProducts.filter({ $0.vendorProductId == transaction.payment.productIdentifier }).first
    }

    private func skProduct(for product: ProductModel) -> SKProduct? {
        return storedProducts.filter({ $0.vendorProductId == product.vendorProductId }).first?.skProduct
    }

    private func purchased(_ transaction: SKPaymentTransaction) {
        let purchaseInfo = self.purchaseInfo(for: transaction)

        // try to get variationId from local array
        var variationId: String? = purchaseInfo?.product.variationId
        if variationId == nil {
            // try to get variationId from storage in case of missing related local data
            variationId = cachedVariationsIds[transaction.payment.productIdentifier]
        }

        guard let receipt = latestReceipt else {
            callBuyProductCompletionAndCleanCallback(for: purchaseInfo, result: .failure(AdaptyError.cantReadReceipt))
            return
        }

        let product = purchaseInfo?.product ?? self.product(for: transaction)

        var discount: ProductDiscountModel?
        if #available(iOS 12.2, OSX 10.14.4, *) {
            // trying to extract promotional offer from transaction
            discount = product?.discounts.filter({ $0.identifier == transaction.payment.paymentDiscount?.identifier }).first
        }
        if discount == nil {
            // fill with introductory offer details by default if possible
            // server handles introductory price application
            discount = product?.introductoryDiscount
        }

        Adapty.extendedValidateReceipt(receipt,
                                       variationId: variationId,
                                       vendorProductId: transaction.payment.productIdentifier,
                                       transactionId: transaction.transactionIdentifier,
                                       originalPrice: product?.price,
                                       discountPrice: discount?.price,
                                       currencyCode: product?.currencyCode,
                                       regionCode: product?.regionCode,
                                       promotionalOfferId: discount?.identifier,
                                       unit: discount?.subscriptionPeriod.unitString(),
                                       numberOfUnits: discount?.subscriptionPeriod.numberOfUnits,
                                       paymentMode: discount?.paymentModeString())
        { purchaserInfo, appleValidationResult, error in
            // return successful response in any case, sync transaction later once more in case of error
            self.callBuyProductCompletionAndCleanCallback(for: purchaseInfo, result: .success((purchaserInfo, receipt, appleValidationResult)))

            if error == nil {
                // clear successfully synced transaction
                self.cachedVariationsIds[transaction.payment.productIdentifier] = nil

                if !Adapty.observerMode {
                    SKPaymentQueue.default().finishTransaction(transaction)
                }
            }
        }
    }

    private func failed(_ transaction: SKPaymentTransaction) {
        cachedVariationsIds[transaction.payment.productIdentifier] = nil

        if !Adapty.observerMode {
            SKPaymentQueue.default().finishTransaction(transaction)
        }

        let purchaseInfo = self.purchaseInfo(for: transaction)

        guard let error = transaction.error as? SKError else {
            if let error = transaction.error {
                callBuyProductCompletionAndCleanCallback(for: purchaseInfo, result: .failure(AdaptyError(with: error)))
            } else {
                callBuyProductCompletionAndCleanCallback(for: purchaseInfo, result: .failure(AdaptyError.productPurchaseFailed))
            }
            return
        }

        callBuyProductCompletionAndCleanCallback(for: purchaseInfo, result: .failure(AdaptyError(with: error)))
    }

    private func restored(_ transaction: SKPaymentTransaction) {
        totalRestoredPurchases += 1
        if !Adapty.observerMode {
            SKPaymentQueue.default().finishTransaction(transaction)
        }
    }

    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        #if os(iOS)
            guard totalRestoredPurchases != 0 else {
                callRestoreCompletionAndCleanCallback(.failure(AdaptyError.noPurchasesToRestore))
                return
            }
        #endif

        guard let receipt = latestReceipt else {
            callRestoreCompletionAndCleanCallback(.failure(AdaptyError.cantReadReceipt))
            return
        }

        Adapty.validateReceipt(receipt) { purchaserInfo, appleValidationResult, error in
            if let error = error {
                self.callRestoreCompletionAndCleanCallback(.failure(error))
            } else {
                self.callRestoreCompletionAndCleanCallback(.success((purchaserInfo, receipt, appleValidationResult)))
            }
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        guard let skError = error as? SKError else {
            callRestoreCompletionAndCleanCallback(.failure(AdaptyError(with: error)))
            return
        }

        callRestoreCompletionAndCleanCallback(.failure(AdaptyError(with: skError)))
    }

    #if os(iOS) && !targetEnvironment(macCatalyst)
        func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
            var json = ["vendor_product_id": product.productIdentifier]
            if #available(iOS 12.2, *), let promotionalOfferId = payment.paymentDiscount?.identifier {
                json["promotional_offer_id"] = promotionalOfferId
            }

            guard let productModel = try? ProductModel(json: json) else {
                return false
            }

            productModel.skProduct = product

            Adapty.delegate?.paymentQueue?(shouldAddStorePaymentFor: productModel, defermentCompletion: { completion in
                self.productsToBuy.append((product: productModel,
                                           payment: payment,
                                           completion: completion))
                SKPaymentQueue.default().add(payment)
            })

            return false
        }
    #endif

    func paymentQueue(_ queue: SKPaymentQueue, didRevokeEntitlementsForProductIdentifiers productIdentifiers: [String]) {
        syncTransactionsHistory()
    }
}
