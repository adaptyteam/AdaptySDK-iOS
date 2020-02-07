//
//  IAPManager.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 12/12/2019.
//

import Foundation
import StoreKit

fileprivate enum IAPManagerError: Error {
    case noProductIDsFound
    case noProductsFound
    case paymentWasCancelled
    case productRequestFailed
    case cantMakePayments
    case noPurchasesToRestore
    case cantReadReceipt
    case productPurchaseFailed
    case missingOfferSigningParams
}

extension IAPManagerError: LocalizedError {
    var errorDescription: String? {
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
        }
    }
}

public typealias BuyProductCompletion = (_ purchaserInfo: PurchaserInfoModel?, _ receipt: String?, _ appleValidationResult: Parameters?, _ product: ProductModel?, _ error: Error?) -> Void
private typealias PurchaseInfoTuple = (product: ProductModel, payment: SKPayment, container: PurchaseContainerModel?, completion: BuyProductCompletion?)

class IAPManager: NSObject {
    
    private var profile: ProfileModel? {
        DefaultsManager.shared.profile
    }
    private var containers: [PurchaseContainerModel]?
    private var productIDs: Set<String>? {
        if let ids = containers?.flatMap({ $0.products.map({ $0.vendorProductId }) }) {
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
    
    private var productsRequest: SKProductsRequest?
    private var purchaseContainersRequestCompletion: PurchaseContainersCompletion?

    private var productsToBuy: [PurchaseInfoTuple] = []

    private var totalRestoredPurchases = 0
    private var restorePurchasesCompletion: ErrorCompletion?
    
    private lazy var apiManager: ApiManager = {
        return ApiManager.shared
    }()
    
    // MARK:- Public
    
    func startObservingPurchases() {
        startObserving()
        
        getContainersAndSyncProducts()
        
        NotificationCenter.default.addObserver(forName: UIApplication.willTerminateNotification, object: nil, queue: .main) { [weak self] (_) in
            self?.stopObserving()
        }
    }
    
    func getPurchaseContainers(_ completion: @escaping PurchaseContainersCompletion) {
        purchaseContainersRequestCompletion = completion
        
        // syncing already in progress
        if productsRequest != nil {
            return
        }
        
        // get containers and all product infos
        getContainersAndSyncProducts()
    }
    
    private func getContainersAndSyncProducts() {
        var params = Parameters()
        if let profileId = profile?.profileId { params["profile_id"] = profileId }
        apiManager.getPurchaseContainers(params: params) { (containers, error) in
            if let error = error {
                // call completion and clear it
                self.callPurchaseContainersCompletionAndCleanCallback(.failure(error))
                return
            }
            
            self.containers = containers
            self.requestProducts()
        }
    }
    
    private func requestProducts() {
        productsRequest?.cancel()
        
        guard let productIDs = productIDs else {
            callPurchaseContainersCompletionAndCleanCallback(.failure(IAPManagerError.noProductIDsFound))
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
            print("Couldn't read receipt data. Error: \(error)")
        }
        
        guard let receipt = receiptData?.base64EncodedString(options: []) else {
            print("No valid local receipt")
            return nil
        }
        
        return receipt
    }
    
    private func createPayment(from product: ProductModel, skProduct: SKProduct, completion: BuyProductCompletion? = nil) {
        let payment = SKPayment(product: skProduct)
        
        productsToBuy.append((product: product,
                              payment: payment,
                              container: containers?.filter({ $0.products.contains(product) }).first,
                              completion: completion))
        
        SKPaymentQueue.default().add(payment)
    }
    
    @available(iOS 12.2, *)
    private func createPayment(from product: ProductModel, discountId: String, skProduct: SKProduct, completion: BuyProductCompletion? = nil) {
        guard let profileId = profile?.profileId else {
            completion?(nil, nil, nil, product, IAPManagerError.missingOfferSigningParams)
            return
        }
        
        ApiManager.shared.signSubscriptionOffer(params: ["product": product.vendorProductId, "offer_code": discountId, "profile_id": profileId]) { (params, error) in
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
                                       container: self.containers?.filter({ $0.products.contains(product) }).first,
                                       completion: completion))
            
            SKPaymentQueue.default().add(payment)
        }
    }
    
}

private extension IAPManager {
    
    // MARK:- Callbacks handling
    
    private func callPurchaseContainersCompletionAndCleanCallback(_ result: Result<[PurchaseContainerModel], Error>) {
        DispatchQueue.main.async {
            switch result {
            case .success(let containers):
                self.purchaseContainersRequestCompletion?(containers, nil)
            case .failure(let error):
                print("Failed to load list of products. Error: \(error.localizedDescription)")
                self.purchaseContainersRequestCompletion?(nil, error)
            }
            
            self.productsRequest = nil
            self.purchaseContainersRequestCompletion = nil
        }
    }
    
    private func callBuyProductCompletionAndCleanCallback(for purchaseInfo: PurchaseInfoTuple?, result: Result<(purchaserInfo: PurchaserInfoModel?, receipt: String, response: Parameters?), Error>) {
        DispatchQueue.main.async {
            switch result {
            case .success(let result):
                purchaseInfo?.completion?(result.purchaserInfo, result.receipt, result.response, purchaseInfo?.product, nil)
            case .failure(let error):
                print("Failed to buy product. Error: \(error.localizedDescription)")
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
                self.restorePurchasesCompletion?(nil)
            case .failure(let error):
                print("Failed to restore purchases. Error: \(error.localizedDescription)")
                self.restorePurchasesCompletion?(error)
            }
            
            self.restorePurchasesCompletion = nil
        }
    }
    
}

extension IAPManager: SKProductsRequestDelegate {
    
    // MARK:- Products list
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        for p in response.products {
            print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
        }
        
        response.products.forEach { skProduct in
            if let products = containers?.flatMap({ $0.products.filter({ $0.vendorProductId == skProduct.productIdentifier }) }) {
                products.forEach({ $0.skProduct = skProduct })
            }
        }
        
        if response.products.count > 0, let containers = containers, containers.count > 0 {
            callPurchaseContainersCompletionAndCleanCallback(.success(containers))
        } else {
            callPurchaseContainersCompletionAndCleanCallback(.failure(IAPManagerError.noProductsFound))
        }
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        callPurchaseContainersCompletionAndCleanCallback(.failure(IAPManagerError.productRequestFailed))
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
    
    private func skProduct(for transaction: SKPaymentTransaction) -> SKProduct? {
        return containers?.flatMap({ $0.products }).filter({ $0.vendorProductId == transaction.payment.productIdentifier }).first?.skProduct
    }
    
    private func purchased(_ transaction: SKPaymentTransaction) {
        let purchaseInfo = self.purchaseInfo(for: transaction)
        
        // try to get variationId from local array
        var variationId: String? = purchaseInfo?.container?.variationId
        if let transactionIdentifier = transaction.transactionIdentifier {
            if let variationId = variationId {
                // store variationId / transactionIdentifier in case of failed receipt validation
                cachedTransactionsIds[transactionIdentifier] = variationId
            } else {
                // try to get variationId from storage in case of missing related container
                variationId = cachedTransactionsIds[transactionIdentifier]
            }
        }
        
        guard let receipt = latestReceipt else {
            callBuyProductCompletionAndCleanCallback(for: purchaseInfo, result: .failure(IAPManagerError.cantReadReceipt))
            return
        }
        
        let skProduct = self.skProduct(for: transaction)
        var discountPrice: NSDecimalNumber?
        if #available(iOS 12.2, *) {
            discountPrice = skProduct?.discounts.filter({ $0.identifier == transaction.payment.paymentDiscount?.identifier }).first?.price
        }
        
        Adapty.validateReceipt(receipt, variationId: variationId, originalPrice: skProduct?.price, discountPrice: discountPrice, priceLocale: skProduct?.priceLocale) { (purchaserInfo, appleValidationResult, error) in
            // return successful response in any case, sync transaction later once more in case of error
            self.callBuyProductCompletionAndCleanCallback(for: purchaseInfo, result: .success((purchaserInfo, receipt, appleValidationResult)))
            
            if error == nil {
                if let transactionIdentifier = transaction.transactionIdentifier {
                    // clear successfully synced transaction
                    self.cachedTransactionsIds[transactionIdentifier] = nil
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }
    
    private func failed(_ transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
        
        let purchaseInfo = self.purchaseInfo(for: transaction)
        
        guard let error = transaction.error as? SKError else {
            callBuyProductCompletionAndCleanCallback(for: purchaseInfo, result: .failure(IAPManagerError.productPurchaseFailed))
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
        SKPaymentQueue.default().finishTransaction(transaction)
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
    
}
