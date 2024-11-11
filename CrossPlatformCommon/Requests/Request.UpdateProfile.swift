//
//  Request.UpdateProfile.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct UpdateProfile: AdaptyPluginRequest {
        static let method = Method.updateProfile

        let params: AdaptyProfileParameters
        init(from jsonDictionary: AdaptyJsonDictionary) throws {
            try self.init(
                params: jsonDictionary.value(forKey: CodingKeys.params)
            )
        }

        init(params: KeyValue) throws {
            self.params = try params.decode(AdaptyProfileParameters.self)
        }

        func execute() async throws -> AdaptyJsonData {
            try await Adapty.updateProfile(params: params)
            return .success()
        }
    }
}

private enum CodingKeys: CodingKey {
    case params
}

public extension AdaptyPlugin {
    @objc static func updateAttribution(
        params: String,
        _ completion: @escaping AdaptyJsonDataCompletion
    ) {
        withCompletion(completion) {
            await Request.UpdateProfile.execute {
                try Request.UpdateProfile(
                    params: .init(key: CodingKeys.params, value: params)
                )
            }
        }
    }
}
