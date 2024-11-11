//
//  AdaptyPluginRequest.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import Adapty
import Foundation

private let log = Log.plugin

protocol AdaptyPluginRequest: Decodable, Sendable {
    static var method: Request.Method { get }
    init(from jsonDictionary: AdaptyJsonDictionary) throws
    func execute() async throws -> AdaptyJsonData
}

extension AdaptyPluginRequest {
    static func execute(instance: () throws -> Self) async -> AdaptyJsonData {
        let request: Self
        do {
            request = try instance()
        } catch {
            let error = AdaptyPluginError.decodingFailed(message: "Request params of method:\(method) is invalid", error)
            log.error(error.message)
            return .failure(error)
        }

        do {
            return try await request.execute()
        } catch {
            return .failure(.callFailed(error))
        }
    }
}
