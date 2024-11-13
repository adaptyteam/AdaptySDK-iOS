//
//  File.swift
//  Adapty
//
//  Created by Aleksey Goncharov on 13.11.2024.
//

import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
package extension AdaptyUI {
    struct View: Encodable {
        let id: String
        let templateId: String
        let placementId: String
        let paywallVariationId: String

        enum CodingKeys: String, CodingKey {
            case id
            case templateId = "template_id"
            case placementId = "placement_id"
            case paywallVariationId = "paywall_variation_id"
        }
    }
}


@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AdaptyPaywallController {
    func toView() -> AdaptyUI.View {
        AdaptyUI.View(
            id: id.uuidString,
            templateId: paywallConfiguration.paywallViewModel.viewConfiguration.templateId,
            placementId: paywallConfiguration.paywallViewModel.paywall.placementId,
            paywallVariationId: paywallConfiguration.paywallViewModel.paywall.variationId
        )
    }
}
