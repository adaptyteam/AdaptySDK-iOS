//
//  AdaptyUI.View+Encodable.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 13.11.2024.
//

import AdaptyUI
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyUI {
    struct View: Encodable {
        let id: String
        let templateId: String
        let paywallId: String
        let paywallVariationId: String

        enum CodingKeys: String, CodingKey {
            case id
            case templateId = "template_id"
            case paywallId = "paywall_id"
            case paywallVariationId = "paywall_variation_id"
        }
    }
}
