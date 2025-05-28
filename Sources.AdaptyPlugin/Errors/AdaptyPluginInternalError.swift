//
//  AdaptyPluginDecodingError.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 07.11.2024.
//

enum AdaptyPluginInternalError: Error {
    case unknownRequest(String)
    case notExist(String)
    case unregister(String)

    var localizedDescription: String {
        switch self {
        case .unknownRequest(let method):
            "Unknown request: \(method)"
        case .notExist(key: let message):
            message
        case .unregister(let message):
            message
        }
    }
}
