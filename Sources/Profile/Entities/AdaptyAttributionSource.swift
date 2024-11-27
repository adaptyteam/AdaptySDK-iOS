//
//  AdaptyAttributionSource.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.09.2022.
//

import Foundation

public enum AdaptyAttributionSource: String, Sendable {
    case adjust
    case appsflyer
    case branch
    case custom
}

extension AdaptyAttributionSource: CustomStringConvertible {
    public var description: String { rawValue }
}
