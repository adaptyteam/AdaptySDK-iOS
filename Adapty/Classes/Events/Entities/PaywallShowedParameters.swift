//
//  PaywallShowedParameters.swift
//  Adapty
//
//  Created by Aleksei Valiano on 07.10.2022.
//

import Foundation

struct PaywallShowedParameters {
    let variationId: String
}

extension PaywallShowedParameters: Codable {
    enum CodingKeys: String, CodingKey {
        case variationId = "variation_id"
    }
}
