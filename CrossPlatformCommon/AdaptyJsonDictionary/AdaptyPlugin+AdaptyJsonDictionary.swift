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
    static func request(json jsonDictionary: AdaptyJsonDictionary) async -> AdaptyJsonData {
        do {
            let method = try jsonDictionary.decode(String.self, forKey: "method")
            return await request(method: method, json: jsonDictionary)
        } catch {
            let error = AdaptyPluginError.decodingFailed(message: "Request data is invalid", error)
            log.error(error.message)
            return AdaptyPluginResult.failure(error).asAdaptyJsonData
        }
    }

    static func request(method: String, json jsonDictionary: AdaptyJsonDictionary) async -> AdaptyJsonData {
        do {
            let requestType = try Request.requestType(for: method)
            return await request(requestType: requestType, json: jsonDictionary)
        } catch {
            let error = AdaptyPluginError.decodingFailed(error)
            log.error(error.message)
            return AdaptyPluginResult.failure(error).asAdaptyJsonData
        }
    }

    private static func request(requestType: AdaptyPluginRequest.Type, json jsonDictionary: AdaptyJsonDictionary) async -> AdaptyJsonData {
        do {
            let params = try requestType.init(from: jsonDictionary)
            return await params.call()
        } catch {
            let error = AdaptyPluginError.decodingFailed(message: "Request params of method:\(requestType.method) is invalid", error)
            log.error(error.message)
            return AdaptyPluginResult.failure(error).asAdaptyJsonData
        }
    }
}
