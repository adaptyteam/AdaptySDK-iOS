//
//  PluginError.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 06.11.2024.
//

import Adapty
import AdaptyUI

public struct AdaptyPluginError: Error, Encodable {
    let errorCode: Int
    let message: String
    let detail: String

    enum CodingKeys: String, CodingKey {
        case errorCode = "adapty_code"
        case message
        case detail
    }
}

extension AdaptyPluginError {
    static func callFailed(_ error: Error) -> AdaptyPluginError {
        if let adaptyError = error as? AdaptyError {
            return adaptyError.asAdaptyPluginError
        }
        
        return AdaptyPluginError(
            errorCode: AdaptyError.ErrorCode.unknown.rawValue,
            message: "Unknown: \(error.localizedDescription)",
            detail: "AdaptyPluginError.unknown: \(String(describing: error))"
        )
    }
    
    static func encodingFailed(message: String? = nil, _ error: Error) -> AdaptyPluginError {
        let message = message ?? "Encoding failed"
        
        let detail = (error as? Encodable)
            .flatMap { try? AdaptyPlugin.encoder.encode($0).asAdaptyJsonString }
        ?? "\(message) \(String(describing: error))"
        
        return .init(
            errorCode: AdaptyError.ErrorCode.encodingFailed.rawValue,
            message: "\(message): \(error.localizedDescription)",
            detail: "AdaptyPluginError.encodingFailed: \(detail)"
        )
    }
    
    static func decodingFailed(message: String? = nil, _ error: Error) -> AdaptyPluginError {
        let message = message ?? "Decoding failed"
        
        let detail = (error as? Encodable)
            .flatMap { try? AdaptyPlugin.encoder.encode($0).asAdaptyJsonString }
        ?? "\(message) \(String(describing: error))"
        
        return .init(
            errorCode: AdaptyError.ErrorCode.decodingFailed.rawValue,
            message: "\(message): \(error.localizedDescription)",
            detail: "AdaptyPluginError.decodingFailed: \(detail)"
        )
    }
}

public extension AdaptyPluginError {
    static func platformViewError(_ message: String) -> AdaptyPluginError {
        return .init(
            errorCode: AdaptyUIError.Code.platformView.rawValue,
            message: message,
            detail: "AdaptyPluginError.platformView initialization Failed"
        )
    }
}
