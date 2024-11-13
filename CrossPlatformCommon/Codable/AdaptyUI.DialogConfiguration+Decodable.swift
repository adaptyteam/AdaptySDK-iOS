//
//  AdaptyUI.DialogConfiguration+Decodable.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 13.11.2024.
//

import AdaptyUI
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyUI {
    struct DialogConfiguration: Decodable {
        let title: String
        let content: String
        let defaultAction: AdaptyUI.DialogConfiguration.Action
        let secondaryAction: AdaptyUI.DialogConfiguration.Action

        enum CodingKeys: String, CodingKey {
            case title
            case content
            case defaultAction = "default_action"
            case secondaryAction = "secondary_action"
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyUI.DialogConfiguration {
    struct Action: Decodable {
        let title: String
    }
}
