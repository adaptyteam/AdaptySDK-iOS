//
//  Request.PresentCodeRedemptionSheet.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import Adapty
import Foundation

extension Request {
    struct PresentCodeRedemptionSheet: AdaptyPluginRequest {
        static let method = Method.presentCodeRedemptionSheet

        init(from jsonDictionary: AdaptyJsonDictionary) throws {}

        init() {}

        func execute() async throws -> AdaptyJsonData {
            Adapty.presentCodeRedemptionSheet()
            return .success()
        }
    }
}

public extension AdaptyPlugin {
    @objc static func presentCodeRedemptionSheet(_ completion: @escaping AdaptyJsonDataCompletion) {
        execute(with: completion) { Request.PresentCodeRedemptionSheet() }
    }
}
