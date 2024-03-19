//
//  AdaptyPaywallShowedParameters.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 07.10.2022.
//

import Foundation

struct AdaptyPaywallShowedParameters {
    let paywallVariationId: String
    let viewConfigurationId: String?
}

extension AdaptyPaywallShowedParameters: Codable {
    enum CodingKeys: String, CodingKey {
        case paywallVariationId = "variation_id"
        case viewConfigurationId = "paywall_builder_id"
    }
}
