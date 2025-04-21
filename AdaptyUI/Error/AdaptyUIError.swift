//
//  AdaptyUIError.swift
//
//
//  Created by Alexey Goncharov on 2023-01-23.
//

import Adapty
import Foundation

public enum AdaptyUIError: Error {
    case platformNotSupported

    case adaptyNotActivated
    case adaptyUINotActivated
    case activateOnce

    case unsupportedTemplate(String)
    case wrongComponentType(String)

    case webKit(Error)
}

extension AdaptyUIError {
    static let AdaptyUIErrorDomain = "AdaptyUIErrorDomain"

    enum Code: Int {
        case platformNotSupported = 4001

        case adaptyNotActivated = 4002
        case adaptyUINotActivated = 4003
        case activateOnce = 4005

        case unsupportedTemplate = 4100
        case wrongComponentType = 4103

        case webKit = 4200
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
        case .unsupportedTemplate: Code.unsupportedTemplate.rawValue
        case .wrongComponentType: Code.wrongComponentType.rawValue
        case .webKit: Code.webKit.rawValue
        }
    }
}
