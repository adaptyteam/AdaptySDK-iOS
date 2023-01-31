//
//  PaywallShowedParameters.swift
//  Adapty
//
//  Created by Aleksei Valiano on 07.10.2022.
//

import Foundation

struct PaywallShowedParameters {
    let paywallVariationId: String
    let viewConfigurationId: String?
}

extension PaywallShowedParameters: Codable {
    enum CodingKeys: String, CodingKey {
        case paywallVariationId = "variation_id"
        case viewConfigurationId = "paywall_builder_id"

    }
}
