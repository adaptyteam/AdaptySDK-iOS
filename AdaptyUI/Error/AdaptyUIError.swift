//
//  AdaptyUIError.swift
//
//
//  Created by Alexey Goncharov on 2023-01-23.
//

import Foundation
import Adapty

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public enum AdaptyUIError: Error {
    case adaptyNotActivated
    case adaptyUINotActivated
    case activateOnce
    
    case encoding(Error)
    case unsupportedTemplate(String)
    case styleNotFound(String)
    case componentNotFound(String)
    case wrongComponentType(String)
    case rendering(Error)
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyUIError {
    static var activateOnceError: AdaptyError { AdaptyError(AdaptyUIError.activateOnce) }
    static var adaptyNotActivatedError: AdaptyError { AdaptyError(AdaptyUIError.adaptyNotActivated) }
}
