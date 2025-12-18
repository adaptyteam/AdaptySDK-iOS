//
//  Dev_AdaptyUIConfiguration.swift
//  AdaptyDeveloperTools
//
//  Created by Aleksey Goncharov on 20.05.2024.
//

import AdaptyUIBuilder

public struct Dev_AdaptyUIConfiguration {
    typealias Wrapped = AdaptyUIConfiguration
    let wrapped: Wrapped
}

#if DEBUG
public extension Dev_AdaptyUIConfiguration {
    static func create(
        assets: String,
        localization: String,
        templates: String?,
        content: String
    ) throws -> Self {
        let configuration = try AdaptyUIConfiguration.create(
            templateId: "basic",
            assets: assets,
            localization: localization,
            templates: templates,
            content: content
        )
        return .init(wrapped: configuration)
    }
}
#endif
