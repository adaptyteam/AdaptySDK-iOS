//
//  AdaptyAttributionSource.swift
//  AdaptySDK
//
//  Created by Ilya Laryionau on 26.12.24.
//

public struct AdaptyAttributionSource: RawRepresentable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public static var adjust: Self { "adjust" }
    public static var appsflyer: Self { "appsflyer" }
    public static var branch: Self { "branch" }
}

extension AdaptyAttributionSource: CustomStringConvertible {
    public var description: String {
        return String(describing: self.rawValue)
    }
}

extension AdaptyAttributionSource: Equatable {}

extension AdaptyAttributionSource: ExpressibleByStringLiteral {
    public init(stringLiteral: String) {
        self.init(rawValue: stringLiteral)
    }
}

extension AdaptyAttributionSource: Hashable {}

extension AdaptyAttributionSource: Sendable {}
