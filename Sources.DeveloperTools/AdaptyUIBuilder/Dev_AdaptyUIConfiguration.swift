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

public extension Dev_AdaptyUIConfiguration {
    static func create(
        templateId: String,
        assets: String,
        localization: String,
        templates: String?,
        content: String,
        script: String? = nil
    ) throws -> Self {
        let configuration = try AdaptyUIConfiguration.create(
            templateId: templateId,
            assets: assets,
            localization: localization,
            templates: templates,
            content: content,
            script: script
        )
        return .init(wrapped: configuration)
    }
}
