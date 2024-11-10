//
//  RequestIsActivated.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 06.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct IsActivated: AdaptyPluginRequest {
        static let method = Method.isActivated

        init(from jsonDictionary: AdaptyJsonDictionary) throws {}

        init() {}

        func call() async -> AdaptyJsonData {
            let result = await Adapty.isActivated
            return AdaptyPluginResult.success(result).asAdaptyJsonData
        }
    }
}

public extension AdaptyPlugin {
    @objc static func isActivated(_ completion: @escaping AdaptyJsonDataCompletion) {
        Request.IsActivated().call(completion)
    }
}
