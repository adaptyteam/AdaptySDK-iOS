//
//  AdaptyOnboarding+Deprecated.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.07.2025.
//

public extension AdaptyOnboarding {
    @available(*, deprecated, renamed: "placement.id")
    var placementId: String { placement.id }

    @available(*, deprecated, renamed: "placement.audienceName")
    var audienceName: String { placement.audienceName }

    @available(*, deprecated, renamed: "placement.revision")
    var revision: Int { placement.revision }

    @available(*, deprecated, renamed: "placement.abTestName")
    var abTestName: String { placement.abTestName }
}
