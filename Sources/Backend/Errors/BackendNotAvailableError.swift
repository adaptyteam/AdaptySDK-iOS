//
//  BackendNotAvailableError.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 31.03.2026.
//

import Foundation

struct BackendNotAvailableError: Error, Hashable, Codable {
    let message: String
}

extension HTTPError {
    static func notAvailable(_ message: String) -> Self {
        .perform(.init(method: .connect, path: "not available"), error: BackendNotAvailableError(message: message))
    }
}
