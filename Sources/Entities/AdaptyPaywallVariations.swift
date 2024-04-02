//
//  AdaptyPaywallVariations.swift
//
//
//  Created by Aleksei Valiano on 26.03.2024
//
//

import Foundation

struct AdaptyPaywallVariation {
    let placementAudienceVersionId: String
    let variationId: String
    let weight: Int
}

extension AdaptyPaywallVariation: CustomStringConvertible {
    public var description: String {
        "(placement_audience_version_id: \(placementAudienceVersionId), variationId: \(variationId), weight: \(weight))"
    }
}

extension AdaptyPaywallVariation: Decodable {
    enum CodingKeys: String, CodingKey {
        case placementAudienceVersionId = "placement_audience_version_id"
        case variationId = "variation_id"
        case weight
    }
}

struct AdaptyPaywallVariations {
    let items: [AdaptyPaywallVariation]
    var placementAudienceVersionId: String? { items.first?.placementAudienceVersionId }

    init(items: [AdaptyPaywallVariation]) {
        self.items = items.sorted(by: { first, second in
            if first.weight == second.weight {
                first.variationId < second.variationId
            } else {
                first.weight < second.weight
            }
        })
    }

    func randomVariationId(profileId: String) -> String? {
        guard let placementAudienceVersionId = items.first?.placementAudienceVersionId else { return nil }
        let data = Data("\(placementAudienceVersionId)-\(profileId)".md5.suffix(8))
        let value: UInt64 = data.withUnsafeBytes { $0.load(as: UInt64.self).bigEndian }
        var weight = Int(value % 100)

        let index = items.firstIndex { item in
            weight -= item.weight
            return weight <= 0
        } ?? (items.count - 1)

        return items[index].variationId
    }
}

extension AdaptyPaywallVariations: Decodable {
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: Backend.CodingKeys.self)

        var arrayContainer = try container.nestedUnkeyedContainer(forKey: .data)

        var items = [AdaptyPaywallVariation]()
        if let count = arrayContainer.count {
            items.reserveCapacity(count)
        }
        while !arrayContainer.isAtEnd {
            let itemContainer = try arrayContainer.nestedContainer(keyedBy: Backend.CodingKeys.self)
            try items.append(itemContainer.decode(AdaptyPaywallVariation.self, forKey: .attributes))
        }

        self.init(items: items)
    }
}
