//
//  AdaptyUIError+CustomAdaptyError.swift
//
//
//  Created by Aleksei Valiano on 27.01.2023
//
//

import Adapty
import Foundation

public extension AdaptyError {
    static let AdaptyUIErrorDomain = "AdaptyUIErrorDomain"
}

extension AdaptyUIError: CustomAdaptyError {
    public static let errorDomain = AdaptyError.AdaptyUIErrorDomain

    public var originalError: Error? {
        switch self {
        case let .encoding(error), let .rendering(error):
            return error
        default:
            return nil
        }
    }

    public var adaptyErrorCode: AdaptyError.ErrorCode {
        switch self {
        case .platformNotSupported:
            return AdaptyError.ErrorCode.unknown
        case .adaptyNotActivated, .adaptyUINotActivated:
            return AdaptyError.ErrorCode.notActivated
        case .activateOnce:
            return AdaptyError.ErrorCode.activateOnceError
        case .encoding:
            return AdaptyError.ErrorCode.encodingFailed
        case .unsupportedTemplate:
            return AdaptyError.ErrorCode.unsupportedData
        case .styleNotFound,
             .wrongComponentType,
             .componentNotFound,
             .rendering:
            return AdaptyError.ErrorCode.decodingFailed
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
        case .platformNotSupported:
            "This platfrom is not supported by AdaptyUI SDK"
        case .adaptyNotActivated:
            "You should activate Adapty SDK before using AdaptyUI"
        case .adaptyUINotActivated:
            "You should activate AdaptyUI SDK before using methods"
        case .activateOnce:
            "You should activate AdaptyUI SDK only once"
        case let .encoding(error):
            "AdaptyUIError.encoding(\(error.localizedDescription))"
        case let .unsupportedTemplate(description):
            "AdaptyUIError.unsupportedTemplate(\(description))"
        case let .styleNotFound(description):
            "AdaptyUIError.styleNotFound(\(description))"
        case let .wrongComponentType(description):
            "AdaptyUIError.wrongComponentType(\(description))"
        case let .componentNotFound(description):
            "AdaptyUIError.componentNotFound(\(description))"
        case let .rendering(error):
            "AdaptyUIError.rendering(\(error.localizedDescription))"
        }
    }
}
