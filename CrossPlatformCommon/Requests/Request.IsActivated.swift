//
//  Request.IsActivated.swift
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

        func execute() async throws -> AdaptyJsonData {
            .success(await Adapty.isActivated)
        }
    }
}

public extension AdaptyPlugin {
    @objc static func isActivated(_ completion: @escaping AdaptyJsonDataCompletion) {
        withCompletion(completion) {
            await Request.IsActivated.execute()
        }
    }
}
