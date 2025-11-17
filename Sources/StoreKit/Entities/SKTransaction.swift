//
//  SKTransaction.swift
//  Adapty
//
//  Created by Aleksei Valiano on 06.08.2025.
//

protocol SKTransaction: Sendable {
    var unfIdentifier: String { get }
    var unfOriginalIdentifier: String { get }
    var unfProductId: String { get }
    var unfOfferId: String? { get }
    var unfEnvironment: String { get }
    var isXcodeEnvironment: Bool { get }
    func logParams(other: EventParameters?) -> EventParameters
}

extension SK1TransactionWithIdentifier: SKTransaction {
    var unfEnvironment: String { "unknown" }
}

extension SK2Transaction: SKTransaction {}
