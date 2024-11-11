//
//  AdaptyPlugin+AdaptyJsonDictionary.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 07.11.2024.
//

import Adapty
import Foundation

private let log = Log.plugin

public extension AdaptyPlugin {
    static func execute(withJson jsonDictionary: AdaptyJsonDictionary) async -> AdaptyJsonData {
        do {
            let method = try jsonDictionary.value(String.self, forKey: "method")
            return await execute(method: method, withJson: jsonDictionary)
        } catch {
            let error = AdaptyPluginError.decodingFailed(message: "Request data is invalid", error)
            log.error(error.message)
            return .failure(error)
        }
    }

    static func execute(method: String, withJson jsonDictionary: AdaptyJsonDictionary) async -> AdaptyJsonData {
        do {
            let requestType = try Request.requestType(for: method)
            return await requestType.execute(withJson: jsonDictionary)
        } catch {
            let error = AdaptyPluginError.decodingFailed(error)
            log.error(error.message)
            return .failure(error)
        }
    }
}

extension AdaptyPluginRequest {
    static func execute(withJson jsonDictionary: AdaptyJsonDictionary) async -> AdaptyJsonData {
        await execute {
            try self.init(from: jsonDictionary)
        }
    }
    
    @inlinable
    static func execute() async -> AdaptyJsonData {
        await execute(withJson: [:])
    }
}
