//
//  Dialog+Configuration.swift
//  Adapty
//
//  Created by Aleksey Goncharov on 13.11.2024.
//

import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
package extension AdaptyUI.DialogConfiguration {
    struct Action: Decodable {
        let title: String?
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
package extension AdaptyUI {
    struct DialogConfiguration: Decodable {
        package let title: String?
        package let content: String?
        package let defaultAction: AdaptyUI.DialogConfiguration.Action
        package let secondaryAction: AdaptyUI.DialogConfiguration.Action?

        enum CodingKeys: String, CodingKey {
            case title
            case content
            case defaultAction = "default_action"
            case secondaryAction = "secondary_action"
        }
    }
}
