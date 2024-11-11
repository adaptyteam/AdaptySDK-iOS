//
//  Request.GetProfile.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct GetProfile: AdaptyPluginRequest {
        static let method = Method.getProfile

        init(from jsonDictionary: AdaptyJsonDictionary) throws {}

        init() {}

        func execute() async throws -> AdaptyJsonData {
            try .success(await Adapty.getProfile())
        }
    }
}

public extension AdaptyPlugin {
    @objc static func getProfile(
        _ completion: @escaping AdaptyJsonDataCompletion
    ) {
        execute(with: completion) { Request.GetProfile() }
    }
}
