//
//  AdaptyFlowShowedParameters.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 07.10.2022.
//

import Foundation

struct AdaptyFlowShowedParameters: Sendable {
    let variationId: String
    let viewConfigurationId: String?
}

extension AdaptyFlowShowedParameters: Codable {
    enum CodingKeys: String, CodingKey {
        case variationId = "variation_id"
        case viewConfigurationId = "paywall_builder_id"
    }
}
