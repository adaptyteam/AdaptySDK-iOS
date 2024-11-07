//
//  PluginError.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 06.11.2024.
//

import Adapty

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
    static func encodingFailed(message: String? = nil, _ error: Error) -> AdaptyPluginError {
        let message = message ?? "Encoding failed"
        if let encodableError = error as? Encodable {
            do {
                let detail = try AdaptyPlugin.encoder.encode(encodableError).asAdaptyJsonString
                return encodingFailed(
                    message: "\(message): \(error.localizedDescription)",
                    detail: detail
                )
            } catch {}
        }

        return encodingFailed(
            message: "\(message): \(error.localizedDescription)",
            detail: "\(message) \(String(describing: error))"
        )
    }

    private static func encodingFailed(message: String, detail: String) -> AdaptyPluginError {
        .init(
            errorCode: AdaptyError.ErrorCode.encodingFailed.rawValue,
            message: message,
            detail: "AdaptyPluginError.encodingFailed: \(detail)"
        )
    }

    static func decodingFailed(message: String? = nil, _ error: Error) -> AdaptyPluginError {
        let message = message ?? "Decoding failed"
        if let encodableError = error as? Encodable {
            do {
                let detail = try AdaptyPlugin.encoder.encode(encodableError).asAdaptyJsonString
                return decodingFailed(
                    message: "\(message): \(error.localizedDescription)",
                    detail: detail
                )
            } catch {}
        }

        return decodingFailed(
            message: "\(message): \(error.localizedDescription)",
            detail: "\(message) \(String(describing: error))"
        )
    }

    private static func decodingFailed(message: String, detail: String) -> AdaptyPluginError {
        .init(
            errorCode: AdaptyError.ErrorCode.decodingFailed.rawValue,
            message: message,
            detail: "AdaptyPluginError.decodingFailed: \(detail)"
        )
    }
}
