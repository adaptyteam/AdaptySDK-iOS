//
//  AdaptyUI.DialogConfiguration+Encodable.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 13.11.2024.
//

import AdaptyUI
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyUI.DialogConfiguration: Decodable {
    enum CodingKeys: String, CodingKey {
        case title
        case content
        case defaultActionTitle = "default_action_title"
        case secondaryActionTitle = "secondary_action_title"
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            title: container.decodeIfPresent(String.self, forKey: .title),
            content: container.decodeIfPresent(String.self, forKey: .content),
            defaultActionTitle: container.decode(String.self, forKey: .defaultActionTitle),
            secondaryActionTitle: container.decodeIfPresent(String.self, forKey: .secondaryActionTitle)
        )
    }
}
