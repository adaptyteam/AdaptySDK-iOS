//
//  Requests.LogLevel.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 07.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct GetLogLevel: AdaptyPluginRequest {
        static let method = Method.getLogLevel
        
        init(from jsonDictionary: AdaptyJsonDictionary) throws {}
        
        init() {}

        func call() async -> AdaptyJsonData {
            let result = Adapty.logLevel
            return AdaptyPluginResult.success(result).asAdaptyJsonData
        }
    }
    
    struct SetLogLevel: AdaptyPluginRequest {
        static let method = Method.setLogLevel
        let value: AdaptyLog.Level
        
        enum CodingKeys: CodingKey {
            case value
        }
        
        init(from jsonDictionary: AdaptyJsonDictionary) throws {
            try self.init(
                value: jsonDictionary.decode(String.self, forKey: CodingKeys.value)
            )
        }
        
        init(value: String) {
            self.value = AdaptyLog.Level(stringLiteral: value)
        }
        
        func call() async -> AdaptyJsonData {
            Adapty.logLevel = value
            return AdaptyPluginResult.success(true).asAdaptyJsonData
        }
    }
}

public extension AdaptyPlugin {
    @objc static func getLogLevel(_ completion: @escaping AdaptyJsonDataCompletion) {
        Request.GetLogLevel().call(completion)
    }
    
    @objc static func setLogLevel(value: String, _ completion: @escaping AdaptyJsonDataCompletion) {
        Request.SetLogLevel(value: value).call(completion)
    }
}
