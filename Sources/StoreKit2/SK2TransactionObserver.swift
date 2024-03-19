//
//  SK2TransactionObserver.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.05.2023
//

import StoreKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
protocol SK2TransactionObserverDelegate: AnyObject {
    func transactionListener(_: SK2TransactionObserver, updatedTransaction transaction: SK2Transaction) async
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
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
                guard let self, let delegate = self.delegate else { break }
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

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension SK1QueueManager: SK2TransactionObserverDelegate {
    func transactionListener(_: SK2TransactionObserver, updatedTransaction transaction: SK2Transaction) async {
        Log.debug("SK2TransactionObserver: Transaction \(transaction.id) (originalID: \(transaction.originalID),  productID: \(transaction.productID), revocationDate:\(transaction.revocationDate?.description ?? "nil"), expirationDate:\(transaction.expirationDate?.description ?? "nil") \((transaction.expirationDate.map { $0 < Date() } ?? false) ? "[expired]" : "") , isUpgraded:\(transaction.isUpgraded) ) ")

        guard transaction.ext.justPurchasedRenewed else { return }
        skProductsManager.fillPurchasedTransaction(variationId: nil, purchasedSK2Transaction: transaction) { [weak self] purchasedTransaction in

            self?.purchaseValidator.validatePurchase(transaction: purchasedTransaction, reason: .observing) { _ in }
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
private extension AdaptyExtension where Extended == SK2Transaction {
    var justPurchasedRenewed: Bool {
        if this.revocationDate != nil {
            return false
        } else if let expirationDate = this.expirationDate, expirationDate < Date() {
            return false
        } else if this.isUpgraded {
            return false
        }

        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            if this.reason == .renewal { return false }
        }

        return true
    }
}
