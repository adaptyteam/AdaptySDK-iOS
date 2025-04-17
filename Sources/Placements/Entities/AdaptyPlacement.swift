//
//  AdaptyPlacement.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 03.04.2025.
//

public struct AdaptyPlacement: Sendable, Identifiable {
    public let id: String
    public let audienceName: String

    /// Current revision (version) of a placement. Every change within a placement creates a new revision.
    public let revision: Int

    /// Parent A/B test name.
    public let abTestName: String

    let placementAudienceVersionId: String  // TODO: extract from placement

    let version: Int64
}

extension AdaptyPlacement: CustomStringConvertible {
    public var description: String {
        "(id: \(id), abTestName: \(abTestName), audienceName: \(audienceName), revision: \(revision))"
    }
}

extension AdaptyPlacement: Codable {
    enum CodingKeys: String, CodingKey {
        case placement
        case id = "developer_id"
        case audienceName = "audience_name"
        case revision
        case abTestName = "ab_test_name"
        case placementAudienceVersionId = "placement_audience_version_id"

        case version = "response_created_at"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let placement = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .placement)

        id = try placement.decode(String.self, forKey: .id)
        audienceName = try placement.decode(String.self, forKey: .audienceName)
        revision = try placement.decode(Int.self, forKey: .revision)
        abTestName = try placement.decode(String.self, forKey: .abTestName)
        placementAudienceVersionId = try placement.decode(String.self, forKey: .placementAudienceVersionId)
        version = try container.decode(Int64.self, forKey: .version)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var placement = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .placement)

        try placement.encode(id, forKey: .id)
        try placement.encode(audienceName, forKey: .audienceName)
        try placement.encode(revision, forKey: .revision)
        try placement.encode(abTestName, forKey: .abTestName)
        try placement.encode(placementAudienceVersionId, forKey: .placementAudienceVersionId)
        try container.encode(version, forKey: .version)
    }
}
