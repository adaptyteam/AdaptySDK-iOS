//
//  File.swift
//  Adapty
//
//  Created by Aleksey Goncharov on 13.11.2024.
//

import Adapty
import AdaptyUIBuilder
import Foundation

package extension AdaptyUI {
    enum PluginError: Error {
        case viewNotFound(String)
        case viewAlreadyPresented(String)
        case viewPresentationError(String)
        case delegateIsNotRegestired
    }
}

extension AdaptyUI.PluginError: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .viewNotFound(viewId): "AdaptyUIError.viewNotFound(\(viewId))"
        case let .viewAlreadyPresented(viewId): "AdaptyUIError.viewAlreadyPresented(\(viewId))"
        case let .viewPresentationError(viewId): "AdaptyUIError.viewPresentationError(\(viewId))"
        case .delegateIsNotRegestired: "AdaptyUIError.delegateIsNotRegestired"
        }
    }
}

extension AdaptyUI.PluginError: CustomAdaptyError {
    public static let errorDomain = AdaptyUIError.AdaptyUIErrorDomain

    public var originalError: Error? { nil }

    public var adaptyErrorCode: AdaptyError.ErrorCode {
        switch self {
        case .viewNotFound: .wrongParam
        case .viewAlreadyPresented: .wrongParam
        case .viewPresentationError: .wrongParam
        case .delegateIsNotRegestired: .unknown
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
        case let .viewNotFound(viewId): "AdaptyUIError.viewNotFound(\(viewId))"
        case let .viewAlreadyPresented(viewId): "AdaptyUIError.viewAlreadyPresented(\(viewId))"
        case let .viewPresentationError(viewId): "AdaptyUIError.viewPresentationError(\(viewId))"
        case .delegateIsNotRegestired: "AdaptyUIError.delegateIsNotRegestired"
        }
    }
}
