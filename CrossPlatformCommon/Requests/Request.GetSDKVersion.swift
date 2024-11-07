//
//  RequestGetSDKVersion.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 06.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct GetSDKVersion: AdaptyPluginRequest {
        static let method = Method.getSDKVersion

        init(from jsonDictionary: AdaptyJsonDictionary) throws {}

        init() {}

        func call() async -> AdaptyJsonData {
            let result = Adapty.SDKVersion
            return AdaptyPluginResult.success(result).asAdaptyJsonData
        }
    }
}

public extension AdaptyPlugin {
    @objc static func SDKVersion(_ completion: @escaping AdaptyJsonDataCompletion) {
        Request.GetSDKVersion().call(completion)
    }
}
