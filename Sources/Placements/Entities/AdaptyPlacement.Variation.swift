//
//  AdaptyPlacement.Variation.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 15.04.2025.
//

import Foundation

extension AdaptyPlacement {
    struct Variation: Sendable, Decodable {
        let variationId: String
        let variationIdByPlacements: [String: String]
        let weight: Int

        enum CodingKeys: String, CodingKey {
            case variationId = "variation_id"
            case weight
            case crossPlacementInfo = "cross_placement_info"
        }

        private enum CrossPlacementCodingKeys: String, CodingKey {
            case variationIdByPlacements = "placement_with_variation_map"
        }

        var isCrossPlacementTest: Bool {
            !variationIdByPlacements.isEmpty
        }

        init(from decoder: Decoder) throws {
            let superContainer = try decoder.container(keyedBy: Backend.CodingKeys.self)

            let container =
                if superContainer.contains(.attributes) {
                    try superContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributes)
                } else {
                    try decoder.container(keyedBy: CodingKeys.self)
                }

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

extension [AdaptyPlacement.Variation] {
    func draw(
        placementAudienceVersionId: String,
        profileId: String
    ) -> Int {
        let countVariations = self.count
        guard countVariations > 1 else { return 0 }

        let data = Data("\(placementAudienceVersionId)-\(profileId)".md5.suffix(8))
        let value: UInt64 = data.withUnsafeBytes { $0.load(as: UInt64.self).bigEndian }
        var weight = Int(value % 100)

        let sortedItems = self
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
        } ?? (countVariations - 1)

        return sortedItems[index].offset
    }
}
