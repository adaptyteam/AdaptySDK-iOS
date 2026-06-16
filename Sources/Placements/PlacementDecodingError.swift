//
//  PlacementDecodingError.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 10.11.2025.
//

enum PlacementDecodingError: Error, Hashable, Codable {
    case notFoundVariationId
}

extension HTTPError {
   func has(placementDecodingError: Set<PlacementDecodingError>) -> Bool {
       guard case let .decoding(_, _, _, _, _, value) = self,
             let value = value as? PlacementDecodingError
       else { return false }

       return placementDecodingError.contains(value)
   }
}
