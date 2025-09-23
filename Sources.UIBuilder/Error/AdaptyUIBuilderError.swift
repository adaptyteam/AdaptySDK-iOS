//
//  File.swift
//  Adapty
//
//  Created by Alexey Goncharov on 9/22/25.
//

import Foundation

public enum AdaptyUIBuilderError: Error {
    case unsupportedTemplate(String)
    case wrongComponentType(String)
}

extension AdaptyUIBuilderError {
    static let AdaptyUIBuilderErrorDomain = "AdaptyUIBuilderErrorDomain"

    enum Code: Int {
        case unsupportedTemplate = 4100
        case wrongComponentType = 4103
    }
}

extension AdaptyUIBuilderError: CustomNSError {
    public static var errorDomain: String { AdaptyUIBuilderErrorDomain }

    public var errorCode: Int {
        switch self {
        case .unsupportedTemplate: Code.unsupportedTemplate.rawValue
        case .wrongComponentType: Code.wrongComponentType.rawValue
        }
    }
}


extension AdaptyUIBuilderError: CustomDebugStringConvertible, CustomStringConvertible {
    public var description: String {
        switch self {
        case let .unsupportedTemplate(templateId):
            "The template with ID '\(templateId)' is not supported or not found. Please contact support."
        case let .wrongComponentType(componentId):
            "Invalid component type for component with ID '\(componentId)'. Please contact support."
        }
     }

    public var debugDescription: String {
        switch self {
        case let .unsupportedTemplate(templateId):
            "AdaptyUIError.unsupportedTemplate (Code: 4100): Template with ID '\(templateId)' is not available or not supported in the current configuration. This may indicate a missing template, version mismatch, or configuration issue. Please contact support."
        case let .wrongComponentType(componentId):
            "AdaptyUIError.wrongComponentType (Code: 4103): Component with ID '\(componentId)' has an invalid or unsupported type configuration. This typically indicates a template structure issue or version incompatibility. Please contact support."
        }
     }
}
