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

extension SK2TransactionManager: StoreKitTransactionManager {}


