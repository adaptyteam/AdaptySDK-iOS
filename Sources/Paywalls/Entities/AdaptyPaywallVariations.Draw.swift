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
        let paywall: AdaptyPaywall
        let variationIdByPlacements: [String: String]
    }
}

extension AdaptyPaywallVariations.Draw {
    var participatesInCrossPlacementABTest: Bool { !variationIdByPlacements.isEmpty }

    func replacedPaywallVersion(_ version: Int64) -> Self {
        var paywall = paywall
        paywall.version = version
        return .init(
            profileId: profileId,
            paywall: paywall,
            variationIdByPlacements: variationIdByPlacements
        )
    }
}

extension AdaptyPaywallVariations.Draw: Decodable {
    init(from decoder: Decoder) throws {
        let items = try [Variation](from: decoder)
        guard let firstItem = items.first else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Paywalls collection is empty"))
        }

        let profileId = try decoder.userInfo.profileId
        let paywall: AdaptyPaywall
        let variationIdByPlacements: [String: String]

        if items.count == 1 {
            paywall = try AdaptyPaywallVariations.paywall(from: decoder, index: 0)
            variationIdByPlacements = firstItem.variationIdByPlacements
        } else {
            let index = Self.draw(
                items: items,
                placementAudienceVersionId: firstItem.placementAudienceVersionId,
                profileId: profileId
            )

            paywall = try AdaptyPaywallVariations.paywall(from: decoder, index: index)
            variationIdByPlacements = items[index].variationIdByPlacements
        }

        self.init(
            profileId: profileId,
            paywall: paywall,
            variationIdByPlacements: variationIdByPlacements
        )
    }

    private static func draw(
        items: [Variation],
        placementAudienceVersionId: String,
        profileId: String
    ) -> Int {
        let data = Data("\(placementAudienceVersionId)-\(profileId)".md5.suffix(8))
        let value: UInt64 = data.withUnsafeBytes { $0.load(as: UInt64.self).bigEndian }
        var weight = Int(value % 100)

        let sortedItems = items
            .enumerated()
            .sorted(by: { first, second in
                if first.element.weight == second.element.weight {
                    first.element.variationId < second.element.variationId
                } else {
                    first.element.weight < second.element.weight
                }
            })

        let index = sortedItems.firstIndex { item in
            weight -= item.element.weight
            return weight <= 0
        } ?? (items.count - 1)

        return sortedItems[index].offset
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

            if container.contains(.crossPlacementInfo),
               !((try? container.decodeNil(forKey: .crossPlacementInfo)) ?? true)
            {
                let crossPlacementInfo = try container.nestedContainer(keyedBy: CrossPlacementCodingKeys.self, forKey: .crossPlacementInfo)
                variationIdByPlacements = try crossPlacementInfo.decode([String: String].self, forKey: .variationIdByPlacements)
            } else {
                variationIdByPlacements = [:]
            }
        }
    }
}
