//
//  Request.AdaptyUIShowDialog.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 13.11.2024.
//

import AdaptyUI
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension Request {
    struct AdaptyUIShowDialog: AdaptyPluginRequest {
        static let method = Method.adaptyUIShowDialog

        let viewId: String
        let configuration: AdaptyUI.DialogConfiguration

        enum CodingKeys: String, CodingKey {
            case viewId = "id"
            case configuration
        }

        init(from params: AdaptyJsonDictionary) throws {
            try self.init(
                viewId: params.value(String.self, forKey: CodingKeys.viewId),
                configuration: params.value(forKey: CodingKeys.configuration)
            )
        }

        init(viewId: String, configuration: KeyValue) throws {
            self.viewId = viewId
            self.configuration = try configuration.decode(AdaptyUI.DialogConfiguration.self)
        }

        func execute() async throws -> AdaptyJsonData {
            try .success(await AdaptyUI.Plugin.showDialog(
                viewId: viewId,
                configuration: configuration
            ))
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public extension AdaptyPlugin {
    @objc static func adaptyUIShowDialog(
        viewId: String,
        configuration: String,
        _ completion: @escaping AdaptyJsonDataCompletion
    ) {
        typealias CodingKeys = Request.AdaptyUIShowDialog.CodingKeys
        execute(with: completion) { try Request.AdaptyUIShowDialog(
            viewId: viewId,
            configuration: KeyValue(key: CodingKeys.configuration, value: configuration)
        ) }
    }
}
