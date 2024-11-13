//
//  Request.AdaptyUIDismissView.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 13.11.2024.
//

import AdaptyUI
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension Request {
    struct AdaptyUIDismissView: AdaptyPluginRequest {
        static let method = Method.adaptyUIDismissView

        let viewId: String

        enum CodingKeys: String, CodingKey {
            case viewId = "id"
        }

        init(from params: AdaptyJsonDictionary) throws {
            try self.init(
                viewId: params.value(String.self, forKey: CodingKeys.viewId)
            )
        }

        init(viewId: String) {
            self.viewId = viewId
        }

        func execute() async throws -> AdaptyJsonData {
            // TODO: implement
            // use viewId 
            return .success()
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public extension AdaptyPlugin {
    @objc static func adaptyUIDismissView(
        viewId: String,
        _ completion: @escaping AdaptyJsonDataCompletion
    ) {
        typealias CodingKeys = Request.AdaptyUIDismissView.CodingKeys
        execute(with: completion) { Request.AdaptyUIDismissView(
            viewId: viewId
        ) }
    }
}
