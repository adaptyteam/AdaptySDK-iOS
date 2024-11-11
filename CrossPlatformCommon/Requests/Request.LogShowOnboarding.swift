//
//  Request.LogShowOnboarding.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct LogShowOnboarding: AdaptyPluginRequest {
        static let method = Method.logShowOnboarding

        let params: AdaptyOnboardingScreenParameters
        init(from jsonDictionary: AdaptyJsonDictionary) throws {
            try self.init(
                params: jsonDictionary.value(forKey: CodingKeys.params)
            )
        }

        init(params: KeyValue) throws {
            self.params = try params.decode(AdaptyOnboardingScreenParameters.self)
        }

        func execute() async throws -> AdaptyJsonData {
            try await Adapty.logShowOnboarding(params)
            return .success()
        }
    }
}

private enum CodingKeys: CodingKey {
    case params
}

public extension AdaptyPlugin {
    @objc static func identify(
        params: String,
        _ completion: @escaping AdaptyJsonDataCompletion
    ) {
        withCompletion(completion) {
            await Request.LogShowOnboarding.execute {
                try Request.LogShowOnboarding(
                    params: .init(key: CodingKeys.params, value: params)
                )
            }
        }
    }
}
