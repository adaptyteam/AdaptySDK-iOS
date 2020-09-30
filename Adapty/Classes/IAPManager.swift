//
//  IAPManager.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 12/12/2019.
//

import Foundation
import StoreKit

public enum IAPManagerError: Error {
    case noProductIDsFound
    case noProductsFound
    case paymentWasCancelled
    case productRequestFailed
    case cantMakePayments
    case noPurchasesToRestore
    case cantReadReceipt
    case productPurchaseFailed
    case missingOfferSigningParams
    case fallbackPaywallsNotRequired
}

extension IAPManagerError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noProductIDsFound: return "No In-App Purchase product identifiers were found."
        case .noProductsFound: return "No In-App Purchases were found."
        case .productRequestFailed: return "Unable to fetch available In-App Purchase products at the moment."
        case .paymentWasCancelled: return "In-App Purchase process was cancelled."
        case .cantMakePayments: return "In-App Purchases are not allowed on this device."
        case .noPurchasesToRestore: return "No purchases to restore."
        case .cantReadReceipt: return "Can't find purchases receipt."
        case .productPurchaseFailed: return "Product purchase failed."
        case .missingOfferSigningParams: return "Missing offer signing required params."
        case .fallbackPaywallsNotRequired: return "Fallback paywalls are not required."
        }
    }
}

public typealias BuyProductCompletion = (_ purchaserInfo: PurchaserInfoModel?, _ receipt: String?, _ appleValidationResult: Parameters?, _ product: ProductModel?, _ error: Error?) -> Void
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
    private var cachedTransactionsIds: [String: String] {
        get {
            return DefaultsManager.shared.cachedTransactionsIds
        }
        set {
            DefaultsManager.shared.cachedTransactionsIds = newValue
        }
    }
    
    private var paywallsRequest: URLSessionDataTask?
    private var productsRequest: SKProductsRequest?
    private var paywallsRequestCompletions: [PaywallsCompletion] = []

    private var productsToBuy: [PurchaseInfoTuple] = []

    private var totalRestoredPurchases = 0
    private var restorePurchasesCompletion: ErrorCompletion?
    
    private var apiManager: ApiManager
    
    // MARK:- Public
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
    
    func startObservingPurchases(_ completion: PaywallsCompletion? = nil) {
        startObserving()
        
        getPaywalls(completion)
        
        NotificationCenter.default.addObserver(forName: UIApplication.willTerminateNotification, object: nil, queue: .main) { [weak self] (_) in
            self?.stopObserving()
        }
    }
    
    func getPaywalls(_ completion: PaywallsCompletion? = nil) {
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
        DispatchQueue.main.async {
            if #available(iOS 11.0, *), let safeAreaInsetsTop = UIApplication.shared.keyWindow?.safeAreaInsets.top {
                topOffset = safeAreaInsetsTop
            } else {
                topOffset = UIApplication.shared.statusBarFrame.height
            }
        }
        
        paywallsRequest =
            apiManager.getPaywalls(params: ["profile_id": profileId, "paywall_padding_top": topOffset]) { (paywalls, products, error) in
            if let error = error {
                // call completion and clear it
                self.callPaywallsCompletionAndCleanCallback(.failure(error))
                return
            }
            
            self.shortPaywalls = paywalls
            self.shortProducts = products
            self.requestProducts()
        }
    }
    
    func setFallbackPaywalls(_ paywalls: String, completion: ErrorCompletion? = nil) {
        // either already have cached paywalls or appstore request is in progress, which means real paywalls were successfully received
        if self.paywalls != nil || productsRequest != nil {
            completion?(IAPManagerError.fallbackPaywallsNotRequired)
            return
        }
        
        var paywallsArray: PaywallsArray?
        do {
            guard
                let paywallsData = paywalls.data(using: .utf8),
                let paywallsJSON = try JSONSerialization.jsonObject(with: paywallsData, options: []) as? Parameters else
            {
                completion?(NetworkResponse.unableToDecode)
                return
            }
            
            paywallsArray = try PaywallsArray(json: paywallsJSON)
        } catch {
            completion?(error)
            return
        }
        
        paywallsRequestCompletions.append { (_, _, error) in
            completion?(error)
        }
        
        shortPaywalls = paywallsArray?.paywalls
        shortProducts = paywallsArray?.products
        requestProducts()
    }
    
    private func requestProducts() {
        productsRequest?.cancel()
        
        guard let productIDs = productIDs else {
            callPaywallsCompletionAndCleanCallback(.failure(IAPManagerError.noProductIDsFound))
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
            completion?(nil, nil, nil, product, IAPManagerError.cantMakePayments)
            return
        }
        
        guard let skProduct = product.skProduct else {
            completion?(nil, nil, nil, product, IAPManagerError.noProductsFound)
            return
        }
        
        if #available(iOS 12.2, *), let offerId = offerId {
            createPayment(from: product, discountId: offerId, skProduct: skProduct, completion: completion)
        } else {
            createPayment(from: product, skProduct: skProduct, completion: completion)
        }
    }
    
    func restorePurchases(_ completion: ErrorCompletion? = nil) {
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
            LoggerManager.logError("No valid local receipt")
            return nil
        }
        
        return receipt
    }
    
    private func createPayment(from product: ProductModel, skProduct: SKProduct, completion: BuyProductCompletion? = nil) {
        let payment = SKPayment(product: skProduct)
        
        productsToBuy.append((product: product,
                              payment: payment,
                              completion: completion))
        
        SKPaymentQueue.default().add(payment)
    }
    
    @available(iOS 12.2, *)
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
                completion?(nil, nil, nil, product, IAPManagerError.missingOfferSigningParams)
                return
            }
            
            let timestamp = NSNumber(value: timestampInt64)
            let payment = SKMutablePayment(product: skProduct)
            payment.applicationUsername = ""
            payment.paymentDiscount = SKPaymentDiscount(identifier: discountId, keyIdentifier: keyIdentifier, nonce: nonce, signature: signature, timestamp: timestamp)
            
            self.productsToBuy.append((product: product,
                                       payment: payment,
                                       completion: completion))
            
            SKPaymentQueue.default().add(payment)
        }
    }
    
}

private extension IAPManager {
    
    // MARK:- Callbacks handling
    
    private func callPaywallsCompletionAndCleanCallback(_ result: Result<(paywalls: [PaywallModel], products: [ProductModel]), Error>) {
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
    
    private func callBuyProductCompletionAndCleanCallback(for purchaseInfo: PurchaseInfoTuple?, result: Result<(purchaserInfo: PurchaserInfoModel?, receipt: String, response: Parameters?), Error>) {
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
    
    private func callRestoreCompletionAndCleanCallback(_ result: Result<Bool, Error>) {
        DispatchQueue.main.async {
            switch result {
            case .success:
                LoggerManager.logMessage("Successfully restored purchases.")
                self.restorePurchasesCompletion?(nil)
            case .failure(let error):
                LoggerManager.logError("Failed to restore purchases.\n\(error.localizedDescription)")
                self.restorePurchasesCompletion?(error)
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
        
        if response.products.count > 0, let paywalls = paywalls, let products = products {
            callPaywallsCompletionAndCleanCallback(.success((paywalls: paywalls, products: products)))
        } else {
            callPaywallsCompletionAndCleanCallback(.failure(IAPManagerError.noProductsFound))
        }
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        callPaywallsCompletionAndCleanCallback(.failure(IAPManagerError.productRequestFailed))
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
    
    private func purchased(_ transaction: SKPaymentTransaction) {
        let purchaseInfo = self.purchaseInfo(for: transaction)
        
        // try to get variationId from local array
        var variationId: String? = purchaseInfo?.product.variationId
        if let transactionIdentifier = transaction.transactionIdentifier {
            if let variationId = variationId {
                // store variationId / transactionIdentifier in case of failed receipt validation
                cachedTransactionsIds[transactionIdentifier] = variationId
            } else {
                // try to get variationId from storage in case of missing related paywall
                variationId = cachedTransactionsIds[transactionIdentifier]
            }
        }
        
        guard let receipt = latestReceipt else {
            callBuyProductCompletionAndCleanCallback(for: purchaseInfo, result: .failure(IAPManagerError.cantReadReceipt))
            return
        }

        let product = purchaseInfo?.product ?? self.product(for: transaction)
        
        var discount: ProductDiscountModel?
        if #available(iOS 12.2, *) {
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
                if let transactionIdentifier = transaction.transactionIdentifier {
                    // clear successfully synced transaction
                    self.cachedTransactionsIds[transactionIdentifier] = nil
                }
                
                if !Adapty.observerMode {
                    SKPaymentQueue.default().finishTransaction(transaction)
                }
            }
        }
    }
    
    private func failed(_ transaction: SKPaymentTransaction) {
        if !Adapty.observerMode {
            SKPaymentQueue.default().finishTransaction(transaction)
        }
        
        let purchaseInfo = self.purchaseInfo(for: transaction)
        
        guard let error = transaction.error as? SKError else {
            if let error = transaction.error {
                callBuyProductCompletionAndCleanCallback(for: purchaseInfo, result: .failure(error))
            } else {
                callBuyProductCompletionAndCleanCallback(for: purchaseInfo, result: .failure(IAPManagerError.productPurchaseFailed))
            }
            return
        }
        
        if error.code != .paymentCancelled {
            callBuyProductCompletionAndCleanCallback(for: purchaseInfo, result: .failure(error))
        } else {
            callBuyProductCompletionAndCleanCallback(for: purchaseInfo, result: .failure(IAPManagerError.paymentWasCancelled))
        }
    }
    
    private func restored(_ transaction: SKPaymentTransaction) {
        totalRestoredPurchases += 1
        if !Adapty.observerMode {
            SKPaymentQueue.default().finishTransaction(transaction)
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        guard totalRestoredPurchases != 0 else {
            callRestoreCompletionAndCleanCallback(.failure(IAPManagerError.noPurchasesToRestore))
            return
        }
        
        guard let receipt = latestReceipt else {
            callRestoreCompletionAndCleanCallback(.failure(IAPManagerError.cantReadReceipt))
            return
        }
        
        Adapty.validateReceipt(receipt) { (_, _, error) in
            if let error = error {
                self.callRestoreCompletionAndCleanCallback(.failure(error))
            } else {
                self.callRestoreCompletionAndCleanCallback(.success(true))
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        guard let skError = error as? SKError else {
            callRestoreCompletionAndCleanCallback(.failure(error))
            return
        }
        
        if skError.code != .paymentCancelled {
            callRestoreCompletionAndCleanCallback(.failure(skError))
        } else {
            callRestoreCompletionAndCleanCallback(.failure(IAPManagerError.paymentWasCancelled))
        }
    }
    
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
    
}
