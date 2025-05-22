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

    let audienceVersionId: String

    let shouldTrackOnboardingShown: Bool

    var version: Int64
}

extension AdaptyPlacement {
    func replace(version: Int64) -> Self {
        var placement = self
        placement.version = version
        return placement
    }
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
        case audienceVersionId = "placement_audience_version_id"
        case shouldTrackOnboardingShown = "is_tracking_purchases"
        case version = "response_created_at"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let placement = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .placement)

        id = try placement.decode(String.self, forKey: .id)
        audienceName = try placement.decode(String.self, forKey: .audienceName)
        revision = try placement.decode(Int.self, forKey: .revision)
        abTestName = try placement.decode(String.self, forKey: .abTestName)
        audienceVersionId = try placement.decode(String.self, forKey: .audienceVersionId)
        shouldTrackOnboardingShown = try placement.decodeIfPresent(Bool.self, forKey: .shouldTrackOnboardingShown) ?? false
        version = try container.decodeIfPresent(Int64.self, forKey: .version) ?? 0
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var placement = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .placement)

        try placement.encode(id, forKey: .id)
        try placement.encode(audienceName, forKey: .audienceName)
        try placement.encode(revision, forKey: .revision)
        try placement.encode(abTestName, forKey: .abTestName)
        try placement.encode(audienceVersionId, forKey: .audienceVersionId)
        if shouldTrackOnboardingShown {
            try placement.encode(shouldTrackOnboardingShown, forKey: .shouldTrackOnboardingShown)
        }
        try container.encode(version, forKey: .version)
    }
}
