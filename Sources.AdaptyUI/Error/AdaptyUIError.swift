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

    case unsupportedTemplate(String)
    case wrongComponentType(String)
}

extension AdaptyUIError {
    static let AdaptyUIErrorDomain = "AdaptyUIErrorDomain"

    enum Code: Int {
        case platformNotSupported = 4001

        case adaptyNotActivated = 4002
        case adaptyUINotActivated = 4003
        case activateOnce = 4005

        case webKit = 4200

        case unsupportedTemplate = 4100
        case wrongComponentType = 4103
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
        case .unsupportedTemplate: Code.unsupportedTemplate.rawValue
        case .wrongComponentType: Code.wrongComponentType.rawValue
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
        case .unsupportedTemplate(let v):
            .unsupportedTemplate(v)
        case .wrongComponentType(let v):
            .wrongComponentType(v)
        }
    }
}
