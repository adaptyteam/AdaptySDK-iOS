//
//  AdaptyConsentToCollectingDataParameters.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.03.2025.
//

import Foundation

struct AdaptyConsentToCollectingDataParameters: Sendable {
    let consent: Bool
}

extension AdaptyConsentToCollectingDataParameters: Codable {
    enum CodingKeys: String, CodingKey {
        case consent
    }
}
