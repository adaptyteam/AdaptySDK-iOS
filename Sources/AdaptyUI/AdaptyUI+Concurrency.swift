//
//  AdaptyUI+Concurrency.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 31.01.2023
//

import Foundation

#if canImport(_Concurrency) && compiler(>=5.5.2)
    @available(macOS 10.15, iOS 13.0.0, watchOS 6.0, tvOS 13.0, *)
    extension AdaptyUI {
        public static func getViewConfiguration(forPaywall paywall: AdaptyPaywall) async throws -> AdaptyUI.ViewConfiguration? {
            return try await withCheckedThrowingContinuation { continuation in
                AdaptyUI.getViewConfiguration(forPaywall: paywall) { result in
                    switch result {
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    case let .success(paywall):
                        continuation.resume(returning: paywall)
                    }
                }
            }
        }
    }
#endif
