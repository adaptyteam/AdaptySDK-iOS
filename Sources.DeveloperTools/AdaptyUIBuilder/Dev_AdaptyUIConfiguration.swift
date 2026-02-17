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
    @available(*, deprecated, message: "Use `create(main:templates:navigators:contents:script:startScreenName:)` instead.")
    static func create(
        assets: String,
        localization: String,
        templates: String? = nil,
        navigators: [String: String]? = nil,
        contents: [AdaptyUISchema.ExampleContent],
        script: String? = nil,
        startScreenName: String?
    ) throws -> Self {
        struct DefaultLocale: Decodable {
            let id: LocaleId
        }
        let defaultLocale = try JSONDecoder().decode(DefaultLocale.self, from: localization.data(using: .utf8) ?? Data())

        let main = ##"""
        {
            "format":"5.0.0",
            "assets":\##(assets),
            "localizations":[\##(localization)],
            "default_localization":"\##(defaultLocale.id)"
        }
        """##

        return try create(
            main: main,
            templates: templates,
            navigators: navigators,
            contents: contents,
            script: script,
            startScreenName: startScreenName
        )
    }

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
