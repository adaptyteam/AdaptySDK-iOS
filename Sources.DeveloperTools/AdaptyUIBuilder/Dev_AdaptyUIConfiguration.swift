//
//  Dev_AdaptyUIConfiguration.swift
//  AdaptyDeveloperTools
//
//  Created by Aleksey Goncharov on 20.05.2024.
//

import AdaptyUIBuilder
import Foundation

public struct Dev_AdaptyUIConfiguration {
    typealias Wrapped = AdaptyUIConfiguration
    let wrapped: Wrapped
}

public extension Dev_AdaptyUIConfiguration {
    static func create(
        main: String,
        templates: String? = nil,
        navigators: [String: String]? = nil,
        contents: [AdaptyUISchema.ExampleContent],
        script: String? = nil,
        startScreenName: String?
    ) throws -> Self {
        let json = try AdaptyUISchema.createJson(
            main: main,
            templates: templates,
            navigators: navigators,
            contents: contents,
            script: script,
            startScreenName: startScreenName
        )

        return try create(json: json)
    }

    static func create(
        json: String
    ) throws -> Self {
        let schema = try AdaptyUISchema(from: json)
        let configuration = try schema.extractUIConfiguration()
        return .init(wrapped: configuration)
    }
}
