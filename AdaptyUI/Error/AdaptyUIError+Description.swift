//
//  AdaptyUIError+Description.swift
//
//
//  Created by Aleksei Valiano on 27.01.2023
//
//

import Foundation

extension AdaptyUIError: CustomDebugStringConvertible, CustomStringConvertible {
    public var description: String { 
        switch self {
        case .platformNotSupported:
            "AdaptyUI SDK is not supported on this platform. Please check the platform compatibility requirements."
        case .adaptyNotActivated:
            "Adapty SDK must be initialized and activated before using AdaptyUI. Please call Adapty.activate() first."
        case .adaptyUINotActivated:
            "AdaptyUI SDK must be initialized before using its methods. Please call AdaptyUI.activate() first."
        case .activateOnce:
            "AdaptyUI SDK can only be activated once per application lifecycle. Multiple activation attempts are not allowed."
        case let .unsupportedTemplate(templateId):
            "The template with ID '\(templateId)' is not supported or not found. Please contact support."
        case let .wrongComponentType(componentId):
            "Invalid component type for component with ID '\(componentId)'. Please contact support."
        case let .webKit(error):
            "An internal WebKit error occurred: \(error). This may be related to web view initialization or rendering issues."
        }
     }

    public var debugDescription: String { 
        switch self {
        case .platformNotSupported:
            "AdaptyUIError.platformNotSupported (Code: 4001): The current platform does not meet the minimum requirements for AdaptyUI SDK. This error typically occurs when trying to use AdaptyUI on an unsupported platform or OS version."
        case .adaptyNotActivated:
            "AdaptyUIError.adaptyNotActivated (Code: 4002): Required dependency Adapty SDK is not initialized. This is a prerequisite error - call Adapty.activate() with valid configuration before initializing AdaptyUI."
        case .adaptyUINotActivated:
            "AdaptyUIError.adaptyUINotActivated (Code: 4003): AdaptyUI SDK is not initialized. Ensure AdaptyUI.activate() is called before any UI-related operations."
        case .activateOnce:
            "AdaptyUIError.activateOnce (Code: 4005): Multiple activation attempts detected. AdaptyUI SDK can only be activated once per application lifecycle. This is a configuration error that should be handled during app initialization."
        case let .unsupportedTemplate(templateId):
            "AdaptyUIError.unsupportedTemplate (Code: 4100): Template with ID '\(templateId)' is not available or not supported in the current configuration. This may indicate a missing template, version mismatch, or configuration issue. Please contact support."
        case let .wrongComponentType(componentId):
            "AdaptyUIError.wrongComponentType (Code: 4103): Component with ID '\(componentId)' has an invalid or unsupported type configuration. This typically indicates a template structure issue or version incompatibility. Please contact support."
        case let .webKit(error):
            "AdaptyUIError.webKit (Code: 4200): Internal WebKit error occurred - \(error). This may affect the UI rendering or functionality. Check the underlying WebKit error for more details about the specific rendering issue."
        }
     }
}
