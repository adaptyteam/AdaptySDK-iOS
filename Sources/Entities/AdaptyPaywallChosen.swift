//
//  AdaptyPaywallChosen.swift
//
//
//  Created by Aleksei Valiano on 26.03.2024
//
//

import Foundation

struct AdaptyPaywallChosen {
    let value: AdaptyPaywall
}

extension AdaptyPaywallChosen: Decodable {
    init(from decoder: any Decoder) throws {
        let items = try [AdaptyPaywallVariation](from: decoder)
        guard let firstItem = items.first else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Paywalls collection is empty"))
        }

        let paywall =
            if items.count == 1 {
                try paywall(from: decoder, index: 0)
            } else {
                try paywall(from: decoder, index: Self.choose(
                    items: items,
                    placementAudienceVersionId: firstItem.placementAudienceVersionId,
                    profileId: decoder.userInfo.profileId ?? ""
                ))
            }

        Adapty.logPaywallVariationChose(.init(
            paywallVariationId: paywall.variationId,
            viewConfigurationId: paywall.viewConfiguration?.id,
            placementAudienceVersionId: firstItem.placementAudienceVersionId
        ))

        self.init(value: paywall)

        func paywall(from decoder: any Decoder, index: Int) throws -> AdaptyPaywall {
            struct Empty: Decodable {}

            var array = try decoder.unkeyedContainer()
            while !array.isAtEnd {
                if array.currentIndex == index {
                    return try array.decode(AdaptyPaywall.self)
                }
                _ = try array.decode(Empty.self)
            }

            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Paywall with index \(index) not found"))
        }
    }
}

extension AdaptyPaywallChosen {
    private struct AdaptyPaywallVariation: Decodable {
        let placementAudienceVersionId: String
        let variationId: String
        let weight: Int

        enum CodingKeys: String, CodingKey {
            case placementAudienceVersionId = "placement_audience_version_id"
            case variationId = "variation_id"
            case weight

            case attributes
        }

        init(from decoder: any Decoder) throws {
            var container = try decoder.container(keyedBy: CodingKeys.self)
            if container.contains(.attributes) {
                container = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributes)
            }

            placementAudienceVersionId = try container.decode(String.self, forKey: .placementAudienceVersionId)
            variationId = try container.decode(String.self, forKey: .variationId)
            weight = try container.decode(Int.self, forKey: .weight)
        }
    }

    private static func choose(
        items: [AdaptyPaywallVariation],
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
}
