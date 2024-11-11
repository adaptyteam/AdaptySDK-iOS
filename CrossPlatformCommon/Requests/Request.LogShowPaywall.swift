//
//  Request.LogShowPaywall.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct LogShowPaywall: AdaptyPluginRequest {
        static let method = Method.logShowPaywall

        let paywall: AdaptyPaywall

        init(from jsonDictionary: AdaptyJsonDictionary) throws {
            try self.init(
                paywall: jsonDictionary.value(forKey: CodingKeys.paywall)
            )
        }

        init(paywall: KeyValue) throws {
            self.paywall = try paywall.decode(AdaptyPaywall.self)
        }

        func execute() async throws -> AdaptyJsonData {
            try await Adapty.logShowPaywall(paywall)
            return .success()
        }
    }
}

private enum CodingKeys: CodingKey {
    case paywall
}

public extension AdaptyPlugin {
    @objc static func logShowPaywall(
        paywall: String,
        _ completion: @escaping AdaptyJsonDataCompletion
    ) {
        withCompletion(completion) {
            await Request.LogShowPaywall.execute {
                try Request.LogShowPaywall(
                    paywall: .init(key: CodingKeys.paywall, value: paywall)
                )
            }
        }
    }
}
