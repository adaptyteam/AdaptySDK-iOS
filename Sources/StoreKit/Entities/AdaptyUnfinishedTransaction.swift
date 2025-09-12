//
//  AdaptyUnfinishedTransaction.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 07.09.2025.
//
import StoreKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public struct AdaptyUnfinishedTransaction: Sendable {
    public let sk2SignedTransaction: VerificationResult<Transaction>
    public func finish() async {
//        mark this transaction client finished
//              do {
//                  try await send to server backendPayload
//              } catch {
//                  return
//              }
//        await sk2Transaction.finish()
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public extension AdaptyUnfinishedTransaction {
    var sk2Transaction: Transaction {
        sk2SignedTransaction.unsafePayloadValue
    }

    var jwsTransaction: String {
        sk2SignedTransaction.jwsRepresentation
    }
}
