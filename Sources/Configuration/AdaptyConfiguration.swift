//
//  AdaptyConfiguration.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.04.2024.
//

import AdaptyLogger
import Foundation

public struct AdaptyConfiguration: Sendable {
    static let `default` = (
        observerMode: false,
        idfaCollectionDisabled: false,
        ipAddressCollectionDisabled: false,
        transactionFinishBehavior: TransactionFinishBehavior.default,
        clearDataOnBackup: false
    )

    let apiKey: String
    let customerUserId: String?
    let appAccountToken: UUID?
    let observerMode: Bool
    let idfaCollectionDisabled: Bool
    let ipAddressCollectionDisabled: Bool
    let callbackDispatchQueue: DispatchQueue?
    let backend: Backend.Configuration
    let logLevel: AdaptyLog.Level?
    let crossPlatformSDK: (name: String, version: String)?
    let transactionFinishBehavior: TransactionFinishBehavior
    let clearDataOnBackup: Bool
}

extension AdaptyConfiguration {
    @AdaptyActor
    static var transactionFinishBehavior = Self.default.transactionFinishBehavior

    var apiKeyPrefix: String {
        String(apiKey.prefix(while: { $0 != "." }))
    }
}
