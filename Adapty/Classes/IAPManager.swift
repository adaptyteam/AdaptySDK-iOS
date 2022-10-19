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
private typealias RefreshReceiptCompletion = (Result<String?, Error>) -> Void
private typealias PurchaseInfoTuple = (product: ProductModel, payment: SKPayment, completion: BuyProductCompletion?)

class IAPManager: NSObject {
    private static var refreshReceiptRequest: SKReceiptRefreshRequest?

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
    private var refreshReceiptCompletions: [RefreshReceiptCompletion] = []

    private var isSyncedAtLeastOnce: Bool = false

    private var productsToBuy: [PurchaseInfoTuple] = []

    private var totalRestoredPurchases = 0
    private var restorePurchasesCompletion: RestorePurchasesCompletion?

    private var apiManager: ApiManager

    fileprivate var storekitEventsCache = [String]()

    // MARK: - Public

    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }

    func startObservingPurchases(syncTransactions: Bool, _ completion: PaywallsCompletion? = nil) {
        startObserving()

        if syncTransactions {
            syncTransactionsHistory { _, paywalls, products, error in
                completion?(paywalls, products, error)
            }
        } else {
            internalGetPaywalls(completion)
        }

        NotificationCenter.default.addObserver(forName: Application.willTerminateNotification, object: nil, queue: .main) { [weak self] _ in
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
        internalGetPaywalls(forceUpdate: false, completion)
    }

    private func internalGetPaywalls(forceUpdate: Bool, _ completion: PaywallsCompletion? = nil) {
        if let completion = completion { paywallsRequestCompletions.append(completion) }

        // syncing already in progress
        if paywallsRequest != nil && forceUpdate == false {
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

        paywallsRequest = apiManager.getPaywalls(params: params) { paywalls, products, error in
            func handlePaywalls(_ paywalls: [PaywallModel]?, products: [ProductModel]?) {
                self.shortPaywalls = paywalls
                self.shortProducts = products
                self.requestProducts()
                if let paywalls = paywalls {
                    Adapty.delegate?.didReceivePaywallsForConfig?(paywalls: paywalls)
                }
            }

            guard let error = error else {
                handlePaywalls(paywalls, products: products)
                return
            }

            if let paywalls = self.paywalls, let products = self.products {
                // request products with cached data
                handlePaywalls(paywalls, products: products)
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
                let paywallsJSON = try JSONSerialization.jsonObject(with: paywallsData, options: []) as? Parameters
            else {
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

        paywallsRequestCompletions.append { [weak self] _, _, error in
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

        logStoreKitEvent(.productsRequestStarted, error: nil)
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

        // re-sync paywalls to get an actual data
        internalGetPaywalls { _, _, _ in
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
            logStoreKitEvent(.receiptNotFound, error: nil)
            return nil
        }

        var receiptData: Data?
        do {
            receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
        } catch {
            LoggerManager.logError("Couldn't read receipt data.\n\(error)")
            logStoreKitEvent(.receiptIsCorrupted, error: error)
        }

        guard let receipt = receiptData?.base64EncodedString(options: []) else {
            LoggerManager.logError(AdaptyError.cantReadReceipt)
            logStoreKitEvent(.receiptIsCorrupted, error: nil)
            return nil
        }

        return receipt
    }

    func syncTransactionsHistory(completion: SyncTransactionsHistoryCompletion? = nil) {
        func getPaywalls(with validationResult: Parameters?) {
            internalGetPaywalls(forceUpdate: true) { paywalls, products, paywallsError in
                completion?(validationResult, paywalls, products, paywallsError)
            }
        }

        func validate(receipt: String) {
            Adapty.validateReceipt(receipt) { _, validationResult, _ in
                // re-sync paywalls so user'll get updated eligibility properties
                getPaywalls(with: validationResult)
            }
        }

        getReceipt { result in
            switch result {
            case let .success(receipt):
                if let receipt = receipt {
                    validate(receipt: receipt)
                } else {
                    getPaywalls(with: nil)
                }
            case let .failure(error):
                getPaywalls(with: nil)
            }
        }
    }

    func syncTransactionsHistoryAndGetPaywalls(onPaywallsLoaded: PaywallsCompletion?, onDeferredReceiptValidation: ValidateReceiptCompletion?) {
        if let localReceipt = latestReceipt {
            // If receipt is presented on the device
            // We just need to force validate it and then fetch the paywalls
            LoggerManager.logMessage("[SYNC] Local receipt is found, proceeding to validation")

            Adapty.validateReceipt(localReceipt) { [weak self] _, _, error in
                if let error = error {
                    LoggerManager.logMessage("[SYNC] Receipt validation ERROR: \(error)")
                    onPaywallsLoaded?(nil, nil, error)
                    return
                }
                
                LoggerManager.logMessage("[SYNC] Receipt validation DONE")

                self?.internalGetPaywalls(forceUpdate: true) { paywalls, products, error in
                    LoggerManager.logMessage("[SYNC] Calling onPaywallsLoaded")
                    onPaywallsLoaded?(paywalls, products, error)
                }
            }
        } else {
            LoggerManager.logMessage("[SYNC] Local receipt is NOT found, requesting the fresh one in the background")

            var paywallsRequestIsFinished = false

            var validationRequestWaitsCallback = false
            var validationPurchaserInfo: PurchaserInfoModel?
            var validationParams: Parameters?
            var validationError: AdaptyError?

            // If receipt is NOT presented on the device
            // We will return paywalls without the receipt (eligibility should be `unknown`) if there wasnt any receipt sync before
            internalGetPaywalls(forceUpdate: true) { paywalls, products, error in
                paywallsRequestIsFinished = true
                LoggerManager.logMessage("[SYNC] Calling onPaywallsLoaded")
                onPaywallsLoaded?(paywalls, products, error)

                if validationRequestWaitsCallback {
                    LoggerManager.logMessage("[SYNC] Calling onDeferredReceiptValidation")
                    onDeferredReceiptValidation?(validationPurchaserInfo, validationParams, validationError)

                    validationRequestWaitsCallback = false
                }
            }

            // We need to refresh it first
            refreshReceipt { result in
                func tryToCallOnDeferredReceiptValidation(purchaserInfo: PurchaserInfoModel?, params: Parameters?, error: AdaptyError?) {
                    if paywallsRequestIsFinished {
                        LoggerManager.logMessage("[SYNC] Calling onDeferredReceiptValidation")
                        onDeferredReceiptValidation?(purchaserInfo, params, error)

                        validationPurchaserInfo = nil
                        validationParams = nil
                        validationError = nil
                        validationRequestWaitsCallback = false
                    } else {
                        validationPurchaserInfo = purchaserInfo
                        validationParams = params
                        validationError = error
                        validationRequestWaitsCallback = true
                    }
                }
                
                switch result {
                case let .success(receipt):
                    if let receipt = receipt {
                        Adapty.validateReceipt(receipt) { purchaserInfo, params, error in
                            if let error = error {
                                LoggerManager.logMessage("[SYNC] Receipt validation ERROR: \(error)")
                            } else {
                                LoggerManager.logMessage("[SYNC] Receipt validation DONE")
                            }

                            tryToCallOnDeferredReceiptValidation(purchaserInfo: purchaserInfo, params: params, error: error)
                        }
                    } else {
                        LoggerManager.logMessage("[SYNC] Local receipt is NOT found after the request, nothing to do anymore")
                        tryToCallOnDeferredReceiptValidation(purchaserInfo: nil, params: nil, error: AdaptyError.cantReadReceipt)
                    }
                case let .failure(error):
                    LoggerManager.logMessage("[SYNC] Receipt refresh ERROR: \(error)")
                    tryToCallOnDeferredReceiptValidation(purchaserInfo: nil, params: nil, error: AdaptyError(with: error))
                }
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

extension IAPManager {
    enum StoreKitEvent: String {
        case receiptRequestStarted = "receipt_request_started"
        case receiptRequestFinished = "receipt_request_finished"
        case receiptRequestFailed = "receipt_request_failed"

        case productsRequestStarted = "products_request_started"
        case productsRequestFinished = "products_request_finished"
        case productsRequestFailed = "products_request_failed"

        case receiptNotFound = "receipt_not_found"
        case receiptIsCorrupted = "receipt_is_corrupted"
    }

    func flushStoreKitEvents() {
        guard !storekitEventsCache.isEmpty else { return }

        let eventData = storekitEventsCache.removeFirst()

        LoggerManager.logMessage("log_storekit_event SENDING \(eventData)")

        KinesisManager.shared.trackEvent(.systemLog, params: ["custom_data": eventData]) { [weak self] error in
            if let error = error {
                LoggerManager.logMessage("log_storekit_event FAILED \(eventData) \(error)")
                self?.storekitEventsCache.insert(eventData, at: 0)
            } else {
                LoggerManager.logMessage("log_storekit_event SENT \(eventData)")
                self?.flushStoreKitEvents()
            }
        }
    }

    private func cacheStoreKitEvent(customData: String) {
        storekitEventsCache.append(customData)
    }

    private func logStoreKitEvent(_ event: StoreKitEvent, error: Error?) {
        var paramsToSend = [String: String]()
        paramsToSend["name"] = event.rawValue
        paramsToSend["ts_collected"] = "\(Date().timeIntervalSince1970)"

        if let skError = error as? SKError {
            paramsToSend["error_skcode"] = "\(skError.code)"
            paramsToSend["error_code"] = "\(skError.errorCode)"
            paramsToSend["error_desc"] = skError.localizedDescription
        } else if let error = error {
            paramsToSend["error_desc"] = error.localizedDescription
        }

        let jsonOptions: JSONSerialization.WritingOptions
        if #available(iOS 11.0, *) {
            jsonOptions = .sortedKeys
        } else {
            jsonOptions = []
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: paramsToSend, options: jsonOptions),
              let jsonString = String(data: jsonData, encoding: .utf8) else { return }

        cacheStoreKitEvent(customData: jsonString)
        flushStoreKitEvents()
    }
}

private extension IAPManager {
    // MARK: - Refresh receipt

    private func getReceipt(completion: @escaping RefreshReceiptCompletion) {
        if let receipt = latestReceipt {
            completion(.success(receipt))
        } else {
            refreshReceipt(completion: completion)
        }
    }

    private func refreshReceipt(completion: @escaping RefreshReceiptCompletion) {
        refreshReceiptCompletions.append(completion)
        if Self.refreshReceiptRequest == nil {
            logStoreKitEvent(.receiptRequestStarted, error: nil)

            Self.refreshReceiptRequest = SKReceiptRefreshRequest()
            Self.refreshReceiptRequest?.delegate = self
            Self.refreshReceiptRequest?.start()
        }
    }
}

private extension IAPManager {
    // MARK: - Callbacks handling

    private func callPaywallsCompletionAndCleanCallback(_ result: Result<(paywalls: [PaywallModel], products: [ProductModel]), AdaptyError>) {
        DispatchQueue.main.async {
            let completions = self.paywallsRequestCompletions

            self.paywallsRequest = nil
            self.productsRequest = nil
            self.paywallsRequestCompletions.removeAll()

            switch result {
            case let .success(data):
                LoggerManager.logMessage("Successfully loaded list of products: [\(self.productIDs?.joined(separator: ",") ?? "")]")
                completions.forEach { completion in
                    completion(data.paywalls, data.products, nil)
                }
            case let .failure(error):
                LoggerManager.logError("Failed to load list of products.\n\(error.localizedDescription)")
                completions.forEach { completion in
                    completion(nil, nil, error)
                }
            }
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
        logStoreKitEvent(.receiptRequestFinished, error: nil)

        Self.refreshReceiptRequest = nil

        let receipt = latestReceipt

        refreshReceiptCompletions.forEach({ $0(.success(receipt)) })
        refreshReceiptCompletions.removeAll()
        request.cancel()
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        logStoreKitEvent(.productsRequestFinished, error: nil)

        for product in response.products {
            LoggerManager.logMessage("Found product: \(product.productIdentifier) \(product.localizedTitle) \(product.price.floatValue)")
        }

        response.products.forEach { skProduct in
            shortPaywalls?.flatMap({ $0.products.filter({ $0.vendorProductId == skProduct.productIdentifier }) }).forEach({ $0.skProduct = skProduct })

            shortProducts?.filter({ $0.vendorProductId == skProduct.productIdentifier }).forEach({ product in
                product.skProduct = skProduct
            })
        }

        if response.products.count != 0 {
            paywalls = shortPaywalls
            products = shortProducts
        }

        // fill missing properties in meta from the same properties in paywalls products
        let paywallsProducts = paywalls?.flatMap({ $0.products })
        products?.forEach({ product in
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
        if let request = request as? SKReceiptRefreshRequest {
            logStoreKitEvent(.receiptRequestFailed, error: error)

            Self.refreshReceiptRequest = nil
            request.cancel()

            refreshReceiptCompletions.forEach({ $0(.failure(error)) })
            refreshReceiptCompletions.removeAll()
            return
        }

        if request is SKProductsRequest {
            logStoreKitEvent(.productsRequestFailed, error: error)
        }

        if #available(iOS 14.0, *), let error = error as? SKError, SKError.Code(rawValue: error.errorCode) == SKError.unknown {
            LoggerManager.logError("Can't fetch products from Store. Please, make sure you run simulator under iOS 14 or if you want to continue using iOS 14 make sure you run it on a real device.")
        }

        callPaywallsCompletionAndCleanCallback(.failure(AdaptyError(with: error)))
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
