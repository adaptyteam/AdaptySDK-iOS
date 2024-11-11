//
//  Request.SDKVersion.swift
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

        func execute() async throws -> AdaptyJsonData {
            .success(Adapty.SDKVersion)
        }
    }
}

public extension AdaptyPlugin {
    @objc static func SDKVersion(_ completion: @escaping AdaptyJsonDataCompletion) {
        withCompletion(completion) {
            await Request.GetSDKVersion.execute()
        }
    }
}
