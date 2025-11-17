//
//  Adapty+UnfinishedTransaction.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 18.09.2025.
//

public extension Adapty {
    nonisolated static func getUnfinishedTransactions() async throws(AdaptyError) -> [AdaptyUnfinishedTransaction] {
        try await withActivatedSDK(methodName: .getUnfinishedTransactions) { sdk async throws(AdaptyError) in
            try await sdk.getUnfinishedTransactions()
        }
    }
}


