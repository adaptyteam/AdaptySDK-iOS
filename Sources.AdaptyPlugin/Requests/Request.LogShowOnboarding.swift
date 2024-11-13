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

        enum CodingKeys: CodingKey {
            case params
        }

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

public extension AdaptyPlugin {
    @objc static func identify(
        params: String,
        _ completion: @escaping AdaptyJsonDataCompletion
    ) {
        typealias CodingKeys = Request.LogShowOnboarding.CodingKeys
        execute(with: completion) { try Request.LogShowOnboarding(
            params: .init(key: CodingKeys.params, value: params)
        ) }
    }
}
