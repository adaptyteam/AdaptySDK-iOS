//
//  AdaptyUISchema+Testing.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 17.02.2026.
//

import Foundation

public extension AdaptyUISchema {
    enum ExampleContent {
        case screen(name: String, value: String)
        case element(name: String, value: String)
    }

    @available(*, deprecated, message: "Use `createJson(main:templates:navigators:contents:script:startScreenName:)` instead.")
    static func createJson(
        formatVersion: String = "5.0.0",
        assets: String,
        localization: String,
        templates: String?,
        navigators: [String: String]?,
        contents: [ExampleContent],
        script: String?,
        startScreenName: String?
    ) throws -> String {
        struct DefaultLocale: Decodable {
            let id: LocaleId
        }
        let defaultLocale = try JSONDecoder().decode(DefaultLocale.self, from: localization.data(using: .utf8) ?? Data())

        let main = ##"""
        {
            "format":"\##(formatVersion)",
            "assets":\##(assets),
            "localizations":[\##(localization)],
            "default_localization":"\##(defaultLocale.id)"
        }
        """##

        return try createJson(
            main: main,
            templates: templates,
            navigators: navigators,
            contents: contents,
            script: script,
            startScreenName: startScreenName
        )
    }

    static func createJson(
        main: String,
        templates: String?,
        navigators: [String: String]?,
        contents: [ExampleContent],
        script: String?,
        startScreenName: String?
    ) throws -> String {
        let main = main.trimmingCharacters(in: .whitespacesAndNewlines).dropLast(1)

        let templates =
            if let templates {
                ##""templates": \##(templates),"##
            } else {
                ""
            }

        let navigators =
            if let navigators {
                navigators.map { ##""\##($0.key)":\##($0.value)"## }.joined(separator: ",")
            } else {
                ""
            }

        let screens: String = contents.map { content in
            switch content {
            case let .screen(name, value):
                ##""\##(name)":\##(value)"##
            case let .element(name, value):
                ##""\##(name)": { "content": \##(value)}"##
            }
        }.joined(separator: ",")

        var script = script ?? ""
        if let startScreenName {
            script += Schema.LegacyScripts.legacyOpenScreen(screenId: startScreenName)
        }

        return try ##"""
        \##(main),
        \##(templates)
        "navigators": "{\##(navigators)}",
        "screens": "{\##(screens)}",
        "scipt": \##(JSONEncoder().encode(script))
        }
        """##
    }
}
