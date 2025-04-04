//
//  File.swift
//  Adapty
//
//  Created by Alexey Goncharov on 4/4/25.
//

import Adapty
import Foundation

public enum AdaptyOnboardingsError: Error {
    case webKit(Source, Error)
}

public extension AdaptyError {
    static let OnboardingsErrorDomain = "AdaptyOnboardingsErrorDomain"
}

extension AdaptyOnboardingsError {
    static func webKit(
        error: Error,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Self {
        .webKit(AdaptyOnboardingsError.Source(file: file, function: function, line: line), error)
    }
}

public extension AdaptyOnboardingsError {
    struct Source: Sendable {
        public let version = Adapty.SDKVersion
        public let file: String
        public let function: String
        public let line: UInt

        package init(file: String = #fileID, function: String = #function, line: UInt = #line) {
            self.file = file
            self.function = function
            self.line = line
        }
    }
}

extension AdaptyOnboardingsError.Source: CustomStringConvertible {
    public var description: String { "[\(version)]: \(file)#\(line)" }
}

extension AdaptyOnboardingsError: CustomAdaptyError {
    public static let errorDomain = AdaptyError.OnboardingsErrorDomain

    public var originalError: Error? {
        switch self {
        case let .webKit(_, error):
            return error
        }
    }

    public var adaptyErrorCode: AdaptyError.ErrorCode {
        switch self {
        case .webKit: AdaptyError.ErrorCode.webkit
        }
    }

    public var errorCode: Int { adaptyErrorCode.rawValue }

    public var errorUserInfo: [String: Any] {
        var data: [String: Any] = [
            AdaptyError.UserInfoKey.description: debugDescription,
        ]

        if let originalError = originalError {
            data[NSUnderlyingErrorKey] = originalError as NSError
        }
        return data
    }

    public var description: String {
        switch self {
        case let .webKit(_, error):
            "AdaptyOnboardings: WebKit internal error: \(error)"
        }
    }
}

extension AdaptyOnboardingsError: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .webKit(_, error):
            "WebKit internal error: \(error)"
        }
    }
}
