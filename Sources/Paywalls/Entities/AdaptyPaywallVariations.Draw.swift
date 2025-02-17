//
//  AdaptyPaywallVariations.Draw.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.03.2024
//

import Foundation

extension AdaptyPaywallVariations {
    struct Draw: Sendable {
        let profileId: String
        let variationId: String
        let placementAudienceVersionId: String
        let variationIdByPlacements: [String: String]
    }
}

extension AdaptyPaywallVariations.Draw: Decodable {
    init(from decoder: Decoder) throws {
        let items = try [Variation](from: decoder)
        guard let firstItem = items.first else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Paywalls collection is empty"))
        }

        let profileId = try decoder.userInfo.profileId

        let variation = if items.count == 1 {
            firstItem
        } else {
            Self.draw(
                items: items,
                placementAudienceVersionId: firstItem.placementAudienceVersionId,
                profileId: profileId
            )
        }

        self.init(
            profileId: profileId,
            variationId: variation.variationId,
            placementAudienceVersionId: variation.placementAudienceVersionId,
            variationIdByPlacements: variation.variationIdByPlacements
        )
    }

    private static func draw(
        items: [Variation],
        placementAudienceVersionId: String,
        profileId: String
    ) -> Variation {
        let data = Data("\(placementAudienceVersionId)-\(profileId)".md5.suffix(8))
        let value: UInt64 = data.withUnsafeBytes { $0.load(as: UInt64.self).bigEndian }
        var weight = Int(value % 100)

        let sortedItems = items
            .sorted(by: { first, second in
                if first.weight == second.weight {
                    first.variationId < second.variationId
                } else {
                    first.weight < second.weight
                }
            })

        let index = sortedItems.firstIndex { item in
            weight -= item.weight
            return weight <= 0
        } ?? (items.count - 1)

        return sortedItems[index]
    }

    private struct Variation: Sendable, Decodable {
        let placementAudienceVersionId: String
        let variationId: String
        let variationIdByPlacements: [String: String]
        let weight: Int

        enum CodingKeys: String, CodingKey {
            case placementAudienceVersionId = "placement_audience_version_id"
            case variationId = "variation_id"
            case weight
            case crossPlacementInfo = "cross_placement_info"

            case attributes
        }

        private enum CrossPlacementCodingKeys: String, CodingKey {
            case variationIdByPlacements = "placement_with_variation_map"
        }

        var isCrossPlacementTest: Bool {
            !variationIdByPlacements.isEmpty
        }

        init(from decoder: Decoder) throws {
            var container = try decoder.container(keyedBy: CodingKeys.self)
            if container.contains(.attributes) {
                container = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributes)
            }

            placementAudienceVersionId = try container.decode(String.self, forKey: .placementAudienceVersionId)
            variationId = try container.decode(String.self, forKey: .variationId)
            weight = try container.decode(Int.self, forKey: .weight)

            if container.contains(.crossPlacementInfo) {
                let crossPlacementInfo = try container.nestedContainer(keyedBy: CrossPlacementCodingKeys.self, forKey: .crossPlacementInfo)
                variationIdByPlacements = try crossPlacementInfo.decode([String: String].self, forKey: .variationIdByPlacements)
            } else {
                variationIdByPlacements = [:]
            }
        }
    }
}
