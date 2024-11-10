//
//  Request.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 07.11.2024.
//

import Foundation

enum Request {
    enum Method: String {
        case getSDKVersion = "get_sdk_version"
        case isActivated = "is_activated"
        case getLogLevel = "get_log_level"
        case setLogLevel = "set_log_level"
    }

    static let allRequests: [Request.Method: AdaptyPluginRequest.Type] = [
        GetSDKVersion.method: GetSDKVersion.self,
        IsActivated.method: IsActivated.self,
        GetLogLevel.method: GetLogLevel.self,
        SetLogLevel.method: SetLogLevel.self
    ]
}

extension Request {
    static func requestType(for method: String) throws -> AdaptyPluginRequest.Type {
        guard let method = Method(rawValue: method) else {
            throw RequestError.uncnownMethod(method)
        }
        return try requestType(for: method)
    }

    private static func requestType(for method: Method) throws -> AdaptyPluginRequest.Type {
        guard let requestType = allRequests[method] else {
            throw RequestError.notFoundRequest(method)
        }
        return requestType
    }
}

public typealias AdaptyJsonDataCompletion = @Sendable (AdaptyJsonData) -> Void

protocol AdaptyPluginRequest: Decodable, Sendable {
    static var method: Request.Method { get }
    init(from jsonDictionary: AdaptyJsonDictionary) throws
    func call() async -> AdaptyJsonData
}

extension AdaptyPluginRequest {
    func call(_ completion: @escaping AdaptyJsonDataCompletion) {
        Task { @MainActor in
            completion(await self.call())
        }
    }
}
