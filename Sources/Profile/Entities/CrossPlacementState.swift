//
//  CrossPlacementState.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.01.2025.
//

import Foundation

struct CrossPlacementState: Sendable, Hashable {
    static let defaultForNewUser = CrossPlacementState(variationIdByPlacements: [:], version: 0)
    let variationIdByPlacements: [String: String]
    let version: Int64
}

extension CrossPlacementState {
    var canParticipateInABTest: Bool {
        variationIdByPlacements.isEmpty
    }

    func contains(placementId: String) -> Bool {
        variationIdByPlacements.keys.contains(placementId)
    }

    func variationId(placementId: String) -> String? {
        variationIdByPlacements[placementId]
    }
}

extension CrossPlacementState: CustomStringConvertible {
    public var description: String {
        "(variationIdByPlacements: \(variationIdByPlacements), version: \(version))"
    }
}

extension CrossPlacementState: Codable {
    private enum CodingKeys: String, CodingKey {
        case variationIdByPlacements = "placement_with_variation_map"
        case version
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        variationIdByPlacements = try container.decode([String: String].self, forKey: .variationIdByPlacements)
        version = try container.decode(Int64.self, forKey: .version)
    }
}
