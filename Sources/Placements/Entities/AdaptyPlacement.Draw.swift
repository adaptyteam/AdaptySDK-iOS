//
//  AdaptyPlacement.Draw.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.03.2024
//

import Foundation

extension AdaptyPlacement {
    struct Draw<Content: AdaptyPlacementContent>: Sendable {
        let profileId: String
        var content: Content
        let placementAudienceVersionId: String
        let variationIdByPlacements: [String: String]
    }
}

extension AdaptyPlacement.Draw {
    var participatesInCrossPlacementABTest: Bool { !variationIdByPlacements.isEmpty }
}

extension AdaptyPlacement.Draw: Decodable {
    init(from decoder: Decoder) throws {
        let profileId = try decoder.userInfo.profileId
        let placement = try decoder.userInfo.placement
        let placementAudienceVersionId = placement.audienceVersionId

        let variations = try [AdaptyPlacement.Variation](from: decoder)

        guard !variations.isEmpty else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Placements contents collection is empty"))
        }

        let index: Int
        if let variationId = decoder.userInfo.placementVariationIdOrNil {
            guard let founded = variations.firstIndex(where: { $0.variationId == variationId }) else {
                throw ResponseDecodingError.notFoundVariationId
            }
            index = founded
        } else {
            index = variations.draw(
                placementAudienceVersionId: placementAudienceVersionId,
                profileId: profileId
            )
        }

        guard variations.indices.contains(index) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Placement content with index \(index) not found"))
        }

        let variation = variations[index]

        let content = try Self.content(from: decoder, index: index)

        self.init(
            profileId: profileId,
            content: content,
            placementAudienceVersionId: placementAudienceVersionId,
            variationIdByPlacements: variation.variationIdByPlacements
        )
    }

    private static func content(from decoder: Decoder, index: Int) throws -> Content {
        var array = try decoder.unkeyedContainer()
        while !array.isAtEnd {
            if array.currentIndex == index {
                
                return try array.decode(Content.self)
            }
            _ = try array.decode(PassObject.self)
        }

        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Placement content with index \(index) not found"))
    }
}

private struct PassObject: Decodable {}
