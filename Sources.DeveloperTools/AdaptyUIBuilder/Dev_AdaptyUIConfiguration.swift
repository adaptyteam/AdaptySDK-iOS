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
        assets: String,
        localization: String,
        templates: String? = nil,
        navigators: String? = nil,
        contents: [AdaptyUIExampleContent],
        script: String? = nil,
        startScreenName: String?
    ) throws -> Self {
        let configuration = try AdaptyUIConfiguration.create(
            assets: assets,
            localization: localization,
            templates: templates,
            navigators: navigators,
            contents: contents,
            script: script,
            startScreenName: startScreenName
        )
        return .init(wrapped: configuration)
    }
}
