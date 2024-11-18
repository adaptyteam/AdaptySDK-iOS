//
//  AdaptyUIError+Description.swift
//
//
//  Created by Aleksei Valiano on 27.01.2023
//
//

import Foundation

extension AdaptyUIError: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .platformNotSupported: return "This platfrom is not supported by AdaptyUI SDK"
        case .adaptyNotActivated: return "You should activate Adapty SDK before using AdaptyUI"
        case .adaptyUINotActivated: return "You should activate AdaptyUI SDK before using methods"
        case .activateOnce: return "You should activate AdaptyUI SDK only once"
        case let .unsupportedTemplate(description): return description
        case let .styleNotFound(description): return description
        case let .wrongComponentType(description): return description
        case let .componentNotFound(description): return description
        case let .encoding(error), let .rendering(error): return error.localizedDescription
        }
    }
}
