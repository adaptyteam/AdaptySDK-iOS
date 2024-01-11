//
//  SK2TransactionObserver.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.05.2023
//

import StoreKit

@available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
protocol SK2TransactionObserverDelegate: AnyObject {
    func transactionListener(_: SK2TransactionObserver, updatedTransaction transaction: SK2Transaction) async
}

@available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
final class SK2TransactionObserver {
    private var updates: Task<Void, Never>?
    private weak var delegate: SK2TransactionObserverDelegate?

    init(delegate: SK2TransactionObserverDelegate?) {
        self.delegate = delegate
        updates = transactionObserverTask()
    }

    deinit {
        updates?.cancel()
        updates = nil
    }

    func transactionObserverTask() -> Task<Void, Never> {
        Task(priority: .utility) { [weak self] in
            for await verificationResult in SK2Transaction.updates {
                guard let self = self, let delegate = self.delegate else { break }
                switch verificationResult {
                case let .unverified(transaction, error):
                    Log.error("SK2TransactionObserver: Transaction \(transaction.id) (originalID: \(transaction.originalID),  productID: \(transaction.productID)) is unverified. Error: \(error.localizedDescription)")
                    continue
                case let .verified(transaction):
                    await delegate.transactionListener(self, updatedTransaction: transaction)
                }
            }
        }
    }
}

@available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
extension SKQueueManager: SK2TransactionObserverDelegate {
    func transactionListener(_ listener: SK2TransactionObserver, updatedTransaction transaction: SK2Transaction) async {
        Log.debug("SK2TransactionObserver: Transaction \(transaction.id) (originalID: \(transaction.originalID),  productID: \(transaction.productID), revocationDate:\(transaction.revocationDate?.description ?? "nil"), expirationDate:\(transaction.expirationDate?.description ?? "nil") \((transaction.expirationDate.map { $0 < Date() } ?? false) ? "[expired]" : "") , isUpgraded:\(transaction.isUpgraded) ) ")

        guard transaction.justPurchasedRenewed else { return }
        skProductsManager.fetchPurchaseProductInfo(variationId: nil, purchasedTransaction: transaction) { [weak self] purchaseProductInfo in

            self?.purchaseValidator.validatePurchase(info: purchaseProductInfo) { _ in }
        }
    }
}

@available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
extension SK2Transaction {
    fileprivate var justPurchasedRenewed: Bool {
        if revocationDate != nil {
            return false
        } else if let expirationDate = expirationDate, expirationDate < Date() {
            return false
        } else if isUpgraded {
            return false
        }

        return true
    }
}
