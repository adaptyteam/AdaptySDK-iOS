//
//  Request.LogLevel.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 07.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct GetLogLevel: AdaptyPluginRequest {
        static let method = "get_log_level"
        
        func execute() async throws -> AdaptyJsonData {
            .success(Adapty.logLevel)
        }
    }
    
    struct SetLogLevel: AdaptyPluginRequest {
        static let method = "set_log_level"
        let value: AdaptyLog.Level
        
        private enum CodingKeys: CodingKey {
            case value
        }
        
        func execute() async throws -> AdaptyJsonData {
            Adapty.logLevel = value
            return .success()
        }
    }
}
