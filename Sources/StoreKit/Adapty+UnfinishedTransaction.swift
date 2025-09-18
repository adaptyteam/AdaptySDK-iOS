//
//  Adapty+UnfinishedTransaction.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 18.09.2025.
//

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public extension Adapty {
    nonisolated static func getUnfinishedTransaction() async throws(AdaptyError) -> [AdaptyUnfinishedTransaction] {
        try await withActivatedSDK(methodName: .getUnfinishedTransaction) { sdk async throws(AdaptyError) in
            try await sdk.getUnfinishedTransaction()
        }
    }
}


