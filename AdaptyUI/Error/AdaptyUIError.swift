//
//  AdaptyUIError.swift
//
//
//  Created by Alexey Goncharov on 2023-01-23.
//

import Foundation

@available(iOS 13.0, *)
public enum AdaptyUIError: Error {
    case encoding(Error)
    case unsupportedTemplate(String)
    case styleNotFound(String)
    case componentNotFound(String)
    case wrongComponentType(String)
    case rendering(Error)
}
