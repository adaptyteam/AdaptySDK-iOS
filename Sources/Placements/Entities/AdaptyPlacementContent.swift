//
//  AdaptyPlacementContent.swift
//  Adapty
//
//  Created by Aleksei Valiano on 08.04.2025.
//

public protocol AdaptyPlacementContent: Sendable, Codable {
    var placement: AdaptyPlacement { get }
    var instanceIdentity: String { get }
    var variationId: String { get }
    var name: String { get }
    var remoteConfig: AdaptyRemoteConfig? { get }
    var hasViewConfiguration: Bool { get }
}

public extension AdaptyPlacementContent {
    @available(*, deprecated, renamed: "placement.id")
    var placementId: String { placement.id }

    @available(*, deprecated, renamed: "placement.audienceName")
    var audienceName: String { placement.audienceName }

    @available(*, deprecated, renamed: "placement.revision")
    var revision: Int { placement.revision }

    @available(*, deprecated, renamed: "placement.abTestName")
    var abTestName: String { placement.abTestName }
}
