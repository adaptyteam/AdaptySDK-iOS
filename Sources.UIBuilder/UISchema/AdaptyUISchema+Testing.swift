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
                ##""\##(name)": {"background": "#000000FF", "content": \##(value)}"##
            }
        }.joined(separator: ",")

        var script = script ?? ""
        if let startScreenName {
            script += Schema.LegacyScripts.legacyOpenDefaultScreen(screenId: startScreenName)
        }

        guard let encodedScript = try String(data: JSONEncoder().encode(script), encoding: .utf8) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Script Corrupted"))
        }

        return ##"""
        \##(main),
        \##(templates)
        "navigators": {\##(navigators)},
        "screens": {\##(screens)},
        "script": \##(encodedScript)
        }
        """##
    }
}
