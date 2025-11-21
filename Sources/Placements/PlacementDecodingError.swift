//
//  PlacementDecodingError.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 10.11.2025.
//

enum PlacementDecodingError: Error, Hashable, Codable {
    case crossPlacementABTestDisabled
    case notFoundVariationId
}
