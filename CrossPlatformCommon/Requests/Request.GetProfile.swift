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
            let profile = try await Adapty.getProfile()
            return .success(profile)
        }
    }
}

private enum CodingKeys: CodingKey {
    case paywall
}

public extension AdaptyPlugin {
    @objc static func getProfile(
        _ completion: @escaping AdaptyJsonDataCompletion
    ) {
        withCompletion(completion) {
            await Request.GetProfile.execute()
        }
    }
}
