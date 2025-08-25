//
//  StoreKitTransactionManager.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 05.10.2024
//

import StoreKit

protocol StoreKitTransactionManager: Actor, Sendable {

    func syncTransactionHistory(for userId: AdaptyUserId) async throws(AdaptyError)
    func syncUnfinishedTransactions()  async throws(AdaptyError)
}

extension StoreKitReceiptManager: StoreKitTransactionManager {
    func syncUnfinishedTransactions()  async throws(AdaptyError) {}
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension SK2TransactionManager: StoreKitTransactionManager {}


