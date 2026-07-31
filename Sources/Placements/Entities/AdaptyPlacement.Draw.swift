//
//  AdaptyPlacement.Draw.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.03.2024
//

import Foundation

extension AdaptyPlacement {
    struct Draw<Content: PlacementContent>: Sendable {
        let date: Date
        let userId: AdaptyUserId
        let content: Content
        let placementAudienceVersionId: String
        let variationIdByPlacements: [String: String]
    }
}

extension AdaptyPlacement.Draw: DecodableWithConfiguration {
    struct DecodingConfiguration: Sendable {
        let userId: AdaptyUserId
        let placement: AdaptyPlacement
        let onboardingRequestLocale: AdaptyLocale?
        var variationId: String?

        init(
            userId: AdaptyUserId,
            placement: AdaptyPlacement,
            onboardingRequestLocale: AdaptyLocale? = nil,
            variationId: String? = nil
        ) {
            self.userId = userId
            self.placement = placement
            self.onboardingRequestLocale = onboardingRequestLocale
            self.variationId = variationId
        }
    }

    var participatesInCrossPlacementABTest: Bool {
        variationIdByPlacements.isNotEmpty
    }

    init(from decoder: Decoder, configuration: DecodingConfiguration) throws {
        let userId = configuration.userId
        let placement = configuration.placement
        let placementAudienceVersionId = placement.audienceVersionId

        let variations = try [AdaptyPlacement.Variation](from: decoder)

        guard variations.isNotEmpty else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Placements contents collection is empty"))
        }

        let index: Int
        if let variationId = configuration.variationId {
            guard let founded = variations.firstIndex(where: { $0.variationId == variationId }) else {
                throw PlacementDecodingError.notFoundVariationId
            }
            index = founded
        } else {
            index = variations.draw(
                placementAudienceVersionId: placementAudienceVersionId,
                userId: userId
            )
        }

        guard variations.indices.contains(index) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Placement content with index \(index) not found"))
        }

        let variation = variations[index]

        let content = try Self.content(from: decoder, index: index, configuration: .init(
            placement: configuration.placement,
            onboardingRequestLocale: configuration.onboardingRequestLocale
        ))

        self.init(
            date: Date(),
            userId: userId,
            content: content,
            placementAudienceVersionId: placementAudienceVersionId,
            variationIdByPlacements: variation.variationIdByPlacements
        )
    }

    private static func content(from decoder: Decoder, index: Int, configuration: AdaptyPlacement.DecodingConfiguration) throws -> Content {
        var array = try decoder.unkeyedContainer()
        while !array.isAtEnd {
            let currentIndex = array.currentIndex
            let contentDecoder = try array.superDecoder()
            if currentIndex == index {
                return try Content(from: contentDecoder, configuration: configuration)
            }
        }

        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Placement content with index \(index) not found"))
    }
}

