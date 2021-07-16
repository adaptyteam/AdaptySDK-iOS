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
private typealias PurchaseInfoTuple = (product: ProductModel, payment: SKPayment, completion: BuyProductCompletion?)

class IAPManager: NSObject {
    
    private var profileId: String {
        DefaultsManager.shared.profileId
    }
    private(set) var paywalls = DefaultsManager.shared.cachedPaywalls {
        didSet {
            DefaultsManager.shared.cachedPaywalls = paywalls
        }
    }
    private var shortPaywalls: [PaywallModel]?
    private(set) var products = DefaultsManager.shared.cachedProducts {
        didSet {
            DefaultsManager.shared.cachedProducts = products
        }
    }
    private var shortProducts: [ProductModel]?
    private var productIDs: Set<String>? {
        if let ids = shortProducts?.map({ $0.vendorProductId }) {
            return Set(ids)
        }
        return nil
    }
    private var cachedVariationsIds: [String: String] {
        get {
            return DefaultsManager.shared.cachedVariationsIds
        }
        set {
            DefaultsManager.shared.cachedVariationsIds = newValue
        }
    }
    
    private var paywallsRequest: URLSessionDataTask?
    private var productsRequest: SKProductsRequest?
    private var paywallsRequestCompletions: [PaywallsCompletion] = []
    
    private var isSyncedAtLeastOnce: Bool = false

    private var productsToBuy: [PurchaseInfoTuple] = []

    private var totalRestoredPurchases = 0
    private var restorePurchasesCompletion: RestorePurchasesCompletion?
    
    private var apiManager: ApiManager
    
    // MARK:- Public
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    func startObservingPurchases(_ completion: PaywallsCompletion? = nil) {
        startObserving()
        
        internalGetPaywalls(completion)
        
        NotificationCenter.default.addObserver(forName: Application.willTerminateNotification, object: nil, queue: .main) { [weak self] (_) in
            self?.stopObserving()
        }
    }
    
    func getPaywalls(forceUpdate: Bool = false, _ completion: @escaping PaywallsCompletion) {
        if forceUpdate {
            // re-sync paywalls and get an actual response
            internalGetPaywalls(completion)
            return
        }
        
        // check for synced and cached data
        if (paywalls != nil || products != nil) && isSyncedAtLeastOnce {
            // call callback instantly with freshly cached data if there are such
            DispatchQueue.main.async {
                completion(self.paywalls, self.products, nil)
            }
        } else {
            // sync paywalls and return data in case of missing cached data
            internalGetPaywalls(completion)
        }
    }
    
    private func internalGetPaywalls(_ completion: PaywallsCompletion? = nil) {
        if let completion = completion { paywallsRequestCompletions.append(completion) }
        
        // syncing already in progress
        if paywallsRequest != nil {
            return
        }
        
        // get paywalls and all product infos
        getPaywallsAndSyncProducts()
    }
    
    private func getPaywallsAndSyncProducts() {
        var topOffset: CGFloat = 0
        
        #if os(iOS)
        if !Thread.isMainThread {
            DispatchQueue.main.sync {
                topOffset = UIApplication.topOffset
            }
        } else {
            topOffset = UIApplication.topOffset
        }
        #endif
        
        let params: Parameters = ["profile_id": profileId, "paywall_padding_top": topOffset, "automatic_paywalls_screen_reporting_enabled": false]

        paywallsRequest = apiManager.getPaywalls(params: params) { (paywalls, products, error) in
            guard let error = error else {
                self.shortPaywalls = paywalls
                self.shortProducts = products
                self.requestProducts()
                return
            }
            
            if error.adaptyErrorCode == .serverError, let paywalls = self.paywalls, let products = self.products {
                // request products with cached data
                self.shortPaywalls = paywalls
                self.shortProducts = products
                self.requestProducts()
            } else {
                self.callPaywallsCompletionAndCleanCallback(.failure(error))
            }
        }
    }
    
    func setFallbackPaywalls(_ paywalls: String, completion: ErrorCompletion? = nil) {
        // either already have cached paywalls or appstore request is in progress, which means real paywalls were successfully received
        if self.paywalls != nil || productsRequest != nil {
            LoggerManager.logMessage("Tried to set Fallback Paywalls but it's unnecessary, since we already have a real paywalls data.")
            handleSetFallbackPaywallsError(nil, completion: completion)
            return
        }
        
        var paywallsArray: PaywallsArray?
        do {
            guard
                let paywallsData = paywalls.data(using: .utf8),
                let paywallsJSON = try JSONSerialization.jsonObject(with: paywallsData, options: []) as? Parameters else
            {
                handleSetFallbackPaywallsError(AdaptyError.unableToDecode, completion: completion)
                return
            }
            
            paywallsArray = try PaywallsArray(json: paywallsJSON)
        } catch let error as AdaptyError {
            handleSetFallbackPaywallsError(error, completion: completion)
            return
        } catch {
            handleSetFallbackPaywallsError(AdaptyError(with: error), completion: completion)
            return
        }
        
        paywallsRequestCompletions.append { [weak self] (_, _, error) in
            self?.handleSetFallbackPaywallsError(error, completion: completion)
        }
        
        shortPaywalls = paywallsArray?.paywalls
        shortProducts = paywallsArray?.products
        requestProducts()
    }
    
    private func handleSetFallbackPaywallsError(_ error: AdaptyError?, completion: ErrorCompletion? = nil) {
        DispatchQueue.main.async {
            completion?(error)
        }
    }
    
    private func requestProducts() {
        productsRequest?.cancel()
        
        guard let productIDs = productIDs else {
            callPaywallsCompletionAndCleanCallback(.failure(AdaptyError.noProductIDsFound))
            return
        }

        productsRequest = SKProductsRequest(productIdentifiers: productIDs)
        productsRequest?.delegate = self
        productsRequest?.start()
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
        product.skProduct = self.skProduct(for: product)
        if product.skProduct != nil {
            // procceed to payment in case of a valid SKProduct
            internalMakePurchase(product: product, offerId: offerId, completion: completion)
            return
        }
        
        // re-sync paywalls to get an actual data
        internalGetPaywalls { (_, _, _) in
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
    
    func syncTransactionsHistory() {
        guard let receipt = latestReceipt else {
            return
        }
        
        Adapty.validateReceipt(receipt) { _, _, _  in
            // re-sync paywalls so user'll get updated eligibility properties
            self.internalGetPaywalls()
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
        apiManager.signSubscriptionOffer(params: ["product": product.vendorProductId, "offer_code": discountId, "profile_id": profileId]) { (params, error) in
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
    
    // MARK:- Callbacks handling
    
    private func callPaywallsCompletionAndCleanCallback(_ result: Result<(paywalls: [PaywallModel], products: [ProductModel]), AdaptyError>) {
        DispatchQueue.main.async {
            switch result {
            case .success(let data):
                LoggerManager.logMessage("Successfully loaded list of products: [\(self.productIDs?.joined(separator: ",") ?? "")]")
                self.paywallsRequestCompletions.forEach { (completion) in
                    completion(data.paywalls, data.products, nil)
                }
            case .failure(let error):
                LoggerManager.logError("Failed to load list of products.\n\(error.localizedDescription)")
                self.paywallsRequestCompletions.forEach { (completion) in
                    completion(nil, nil, error)
                }
            }
            
            self.paywallsRequest = nil
            self.productsRequest = nil
            self.paywallsRequestCompletions.removeAll()
        }
    }
    
    private func callBuyProductCompletionAndCleanCallback(for purchaseInfo: PurchaseInfoTuple?, result: Result<(purchaserInfo: PurchaserInfoModel?, receipt: String, response: Parameters?), AdaptyError>) {
        DispatchQueue.main.async {
            // additional logs for success / error were moved to higher level because of the multiple calls in parent methods
            switch result {
            case .success(let result):
                purchaseInfo?.completion?(result.purchaserInfo, result.receipt, result.response, purchaseInfo?.product, nil)
            case .failure(let error):
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
            case .success(let result):
                LoggerManager.logMessage("Successfully restored purchases.")
                self.restorePurchasesCompletion?(result.purchaserInfo, result.receipt, result.response, nil)
            case .failure(let error):
                LoggerManager.logError("Failed to restore purchases.\n\(error.localizedDescription)")
                self.restorePurchasesCompletion?(nil, nil, nil, error)
            }
            
            self.restorePurchasesCompletion = nil
        }
    }
    
}

extension IAPManager: SKProductsRequestDelegate {
    
    // MARK:- Products list
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        for product in response.products {
            LoggerManager.logMessage("Found product: \(product.productIdentifier) \(product.localizedTitle) \(product.price.floatValue)")
        }
        
        response.products.forEach { skProduct in
            shortPaywalls?.flatMap({ $0.products.filter({ $0.vendorProductId == skProduct.productIdentifier }) }).forEach({ $0.skProduct = skProduct })
            
            shortProducts?.filter({ $0.vendorProductId == skProduct.productIdentifier }).forEach({ (product) in
                product.skProduct = skProduct
            })
        }
        
        if response.products.count != 0 {
            paywalls = shortPaywalls
            products = shortProducts
        }
        
        // fill missing properties in meta from the same properties in paywalls products
        let paywallsProducts = paywalls?.flatMap({ $0.products })
        products?.forEach({ (product) in
            if let paywallProduct = paywallsProducts?.filter({ $0.vendorProductId == product.vendorProductId }).first {
                product.fillMissingProperties(from: paywallProduct)
            }
        })
        
        isSyncedAtLeastOnce = true
        
        if response.products.count > 0, let paywalls = paywalls, let products = products {
            callPaywallsCompletionAndCleanCallback(.success((paywalls: paywalls, products: products)))
        } else {
            callPaywallsCompletionAndCleanCallback(.failure(AdaptyError.noProductsFound))
        }
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        if #available(iOS 14.0, *), let error = error as? SKError, SKError.Code(rawValue: error.errorCode) == SKError.unknown {
            LoggerManager.logError("Can't fetch products from Store. Please, make sure you run simulator under iOS 14 or if you want to continue using iOS 14 make sure you run it on a real device.")
        }
        
        callPaywallsCompletionAndCleanCallback(.failure(AdaptyError(with: error)))
    }
    
}

extension IAPManager: SKPaymentTransactionObserver {
    
    // MARK:- Transactions
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { (transaction) in
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
        return products?.filter({ $0.vendorProductId == transaction.payment.productIdentifier }).first
    }
    
    private func skProduct(for product: ProductModel) -> SKProduct? {
        return products?.filter({ $0.vendorProductId == product.vendorProductId }).first?.skProduct
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
        { (purchaserInfo, appleValidationResult, error) in
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
        guard totalRestoredPurchases != 0 else {
            callRestoreCompletionAndCleanCallback(.failure(AdaptyError.noPurchasesToRestore))
            return
        }
        
        guard let receipt = latestReceipt else {
            callRestoreCompletionAndCleanCallback(.failure(AdaptyError.cantReadReceipt))
            return
        }
        
        Adapty.validateReceipt(receipt) { (purchaserInfo, appleValidationResult, error) in
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
        
        Adapty.delegate?.paymentQueue?(shouldAddStorePaymentFor: productModel, defermentCompletion: { (completion) in
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
