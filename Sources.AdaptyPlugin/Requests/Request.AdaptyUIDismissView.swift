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
        static let method = "adapty_ui_dismiss_view"

        let viewId: String
        let destroy: Bool

        enum CodingKeys: String, CodingKey {
            case viewId = "id"
            case destroy
        }

        init(from params: AdaptyJsonDictionary) throws {
            try self.init(
                viewId: params.value(String.self, forKey: CodingKeys.viewId),
                destroy: params.valueIfPresent(Bool.self, forKey: CodingKeys.destroy)
            )
        }

        init(viewId: String, destroy: Bool?) {
            self.viewId = viewId
            self.destroy = destroy ?? false
        }

        func execute() async throws -> AdaptyJsonData {
            try await AdaptyUI.Plugin.dismissView(
                viewId: viewId,
                destroy: destroy
            )
            return .success()
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public extension AdaptyPlugin {
    @objc static func adaptyUIDismissView(
        viewId: String,
        destroy: Bool,
        _ completion: @escaping AdaptyJsonDataCompletion
    ) {
        typealias CodingKeys = Request.AdaptyUIDismissView.CodingKeys
        execute(with: completion) { Request.AdaptyUIDismissView(
            viewId: viewId,
            destroy: destroy
        ) }
    }
}
