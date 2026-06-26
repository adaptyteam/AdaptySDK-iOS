//
//  AdaptyUIError.swift
//
//
//  Created by Alexey Goncharov on 2023-01-23.
//

import Foundation

public enum AdaptyUIError: Error {
    case platformNotSupported

    case adaptyNotActivated
    case adaptyUINotActivated
    case activateOnce

    case webKit(Error)

    case wrongComponentType(String)
    case wrongAssetType(String)

    case jsException(String)

    case navigatorNotFound(String)
    case invalidActionURL(String)
}

public extension AdaptyUIError {
    static let AdaptyUIErrorDomain = "AdaptyUIErrorDomain"

    enum Code: Int {
        case platformNotSupported = 4001

        case adaptyNotActivated = 4002
        case adaptyUINotActivated = 4003
        case activateOnce = 4005

        case webKit = 4200

        case wrongComponentType = 4103
        case wrongAssetType = 4104
        case jsException = 4105
        case navigatorNotFound = 4106
        case invalidActionURL = 4107

        case platformView = 4300
    }
}

extension AdaptyUIError: CustomNSError {
    public static var errorDomain: String { AdaptyUIErrorDomain }

    public var errorCode: Int {
        switch self {
        case .platformNotSupported: Code.platformNotSupported.rawValue
        case .adaptyNotActivated: Code.adaptyNotActivated.rawValue
        case .adaptyUINotActivated: Code.adaptyUINotActivated.rawValue
        case .activateOnce: Code.activateOnce.rawValue
        case .webKit: Code.webKit.rawValue
        case .wrongComponentType: Code.wrongComponentType.rawValue
        case .wrongAssetType: Code.wrongAssetType.rawValue
        case .jsException: Code.jsException.rawValue
        case .navigatorNotFound: Code.navigatorNotFound.rawValue
        case .invalidActionURL: Code.invalidActionURL.rawValue
        }
    }
}

import Adapty

struct AdaptyUIUnknownError: CustomAdaptyError {
    let error: Error

    init(error: Error) {
        self.error = error
    }

    var originalError: Error? { error }
    let adaptyErrorCode = AdaptyError.ErrorCode.unknown

    var description: String { error.localizedDescription }
    var debugDescription: String { error.localizedDescription }
}

extension Error {
    var asAdaptyError: AdaptyError {
        if let adaptyError = self as? AdaptyError {
            return adaptyError
        } else if let customError = self as? CustomAdaptyError {
            return customError.asAdaptyError
        }

        return AdaptyError(AdaptyUIUnknownError(error: self))
    }
}

import AdaptyUIBuilder

extension AdaptyUIBuilderError {
    var toAdaptyUIError: AdaptyUIError {
        switch self {
        case .wrongComponentType(let v):
            .wrongComponentType(v)
        case .wrongAssetType(let v):
            .wrongAssetType(v)
        case .jsException(let v):
            .jsException(v)
        case .navigatorNotFound(let v):
            .navigatorNotFound(v)
        case .invalidActionURL(let v):
            .invalidActionURL(v)
        }
    }
}
