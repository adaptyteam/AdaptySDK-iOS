//
//  AdaptyPlugin+AdaptyJsonData.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 07.11.2024.
//

import Adapty
import Foundation

private let log = Log.plugin

public extension AdaptyPlugin {
    static func execute(withJson jsonData: AdaptyJsonData) async -> AdaptyJsonData {
        struct Body: Decodable {
            let method: String
        }

        do {
            let method = try jsonData.decode(Body.self).method
            return await execute(method: method, withJson: jsonData)
        } catch {
            let error = AdaptyPluginError.decodingFailed(message: "Request data is invalid", error)
            log.error(error.message)
            return .failure(error)
        }
    }

    static func execute(method: String, withJson jsonData: AdaptyJsonData) async -> AdaptyJsonData {
        do {
            let requestType = try Request.requestType(for: method)
            return await execute(requestType: requestType, withJson: jsonData)
        } catch {
            let error = AdaptyPluginError.decodingFailed(error)
            log.error(error.message)
            return .failure(error)
        }
    }

    private static func execute<RequestType: AdaptyPluginRequest>(requestType: RequestType.Type, withJson jsonData: AdaptyJsonData) async -> AdaptyJsonData {
        await execute {
            try jsonData.decode(requestType)
        }
    }
}
