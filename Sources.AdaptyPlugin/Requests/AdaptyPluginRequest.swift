//
//  AdaptyPluginRequest.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import Adapty
import Foundation

private let log = Log.plugin

public protocol AdaptyPluginRequest: Decodable, Sendable {
    static var method: String { get }
    func execute() async throws -> AdaptyJsonData
}

extension AdaptyPlugin {
    static func execute<Request: AdaptyPluginRequest>(instance: () throws -> Request) async -> AdaptyJsonData {
        let request: Request
        do {
            request = try instance()
        } catch {
            let error = AdaptyPluginError.decodingFailed(message: "Request params of method:\(Request.method) is invalid", error)
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
