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
