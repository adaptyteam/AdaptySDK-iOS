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
    static func request(json jsonData: AdaptyJsonData) async -> AdaptyJsonData {
        struct Body: Decodable {
            let method: String
        }

        do {
            let method = try jsonData.decode(Body.self).method
            return await request(method: method, json: jsonData)
        } catch {
            let error = AdaptyPluginError.decodingFailed(message: "Request data is invalid", error)
            log.error(error.message)
            return AdaptyPluginResult.failure(error).asAdaptyJsonData
        }
    }

    static func request(method: String, json jsonData: AdaptyJsonData) async -> AdaptyJsonData {
        do {
            let requestType = try Request.requestType(for: method)
            return await request(requestType: requestType, json: jsonData)
        } catch {
            let error = AdaptyPluginError.decodingFailed(error)
            log.error(error.message)
            return AdaptyPluginResult.failure(error).asAdaptyJsonData
        }
    }

    private static func request(requestType: AdaptyPluginRequest.Type, json jsonData: AdaptyJsonData) async -> AdaptyJsonData {
        do {
            let params = try jsonData.decode(requestType)
            return await params.call()
        } catch {
            let error = AdaptyPluginError.decodingFailed(message: "Request params of method:\(requestType.method) is invalid", error)
            log.error(error.message)
            return AdaptyPluginResult.failure(error).asAdaptyJsonData
        }
    }
}
