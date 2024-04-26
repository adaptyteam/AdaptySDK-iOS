//
//  AdaptyUIError+CustomAdaptyError.swift
//
//
//  Created by Aleksei Valiano on 27.01.2023
//
//

import Adapty
import Foundation

extension AdaptyError {
    public static let AdaptyUIErrorDomain = "AdaptyUIErrorDomain"
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
        case let .encoding(error):
            return "AdaptyUIError.encoding(\(error.localizedDescription))"
        case let .unsupportedTemplate(description):
            return "AdaptyUIError.unsupportedTemplate(\(description))"
        case let .styleNotFound(description):
            return "AdaptyUIError.styleNotFound(\(description))"
        case let .wrongComponentType(description):
            return "AdaptyUIError.wrongComponentType(\(description))"
        case let .componentNotFound(description):
            return "AdaptyUIError.componentNotFound(\(description))"
        case let .rendering(error):
            return "AdaptyUIError.rendering(\(error.localizedDescription))"
        }
    }
}
