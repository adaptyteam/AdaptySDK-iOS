//
//  StoreKitTransactionManager.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 05.10.2024
//

import StoreKit

protocol StoreKitTransactionManager: Actor, Sendable {
    func syncTransactions(for profileId: String) async throws -> VH<AdaptyProfile>?
}
