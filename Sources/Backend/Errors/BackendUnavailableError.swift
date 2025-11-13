//
//  BackendUnavailableError.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 13.11.2025.
//

import Foundation

public enum BackendUnavailableError: Error, Hashable, Codable {
    case unauthorized
    case blockedUntil(Date?)
}

extension BackendUnavailableError {
    var isBlocked: Bool {
        switch self {
        case .unauthorized:
            return true
        case .blockedUntil(let date):
            guard let date else { return false }
            return Date() < date
        }
    }

    @inlinable
    func merge(other: BackendUnavailableError) -> BackendUnavailableError? {
        switch (self, other) {
        case (.unauthorized, _):
            return self
        case (_, .unauthorized):
            return other
        case (.blockedUntil(let selfData), .blockedUntil(let otherData)):
            guard let otherData else { return self }
            guard let selfData, selfData < otherData else { return other }
            return self
        }
    }

    @inlinable
    func merge(other: BackendUnavailableError?) -> BackendUnavailableError? {
        guard let other else { return self }
        return self.merge(other: other)
    }
}

extension BackendUnavailableError? {
    @inlinable
    func merge(other: BackendUnavailableError?) -> BackendUnavailableError? {
        guard let self else { return other }
        return self.merge(other: other)
    }
}
