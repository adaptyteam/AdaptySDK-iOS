//
//  SKTransaction.swift
//  Adapty
//
//  Created by Aleksei Valiano on 06.08.2025.
//

protocol SKTransaction: Sendable {
    var unfIdentifier: String { get }
    var unfOriginalIdentifier: String { get }
    var unfProductID: String { get }
    var unfOfferId: String? { get }
    var unfEnvironment: String { get }

    var logParams: EventParameters { get }
}

extension SK1TransactionWithIdentifier: SKTransaction {
    var unfEnvironment: String { "unknown" }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension SK2Transaction: SKTransaction {}
