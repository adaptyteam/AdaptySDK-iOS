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

    private struct MainObject: Decodable {
        let format: Schema.Version
    }

    static func createJson(
        main: String,
        templates: String?,
        navigators: [String: String]?,
        contents: [ExampleContent],
        script: String?,
        startScreenName: String?
    ) throws -> String {
        let isNotLegacy = try JSONDecoder()
            .decode(MainObject.self, from: main.data(using: .utf8) ?? Data())
            .format
            .isNotLegacyVersion

        var result: [String] = []
        result.append(
            String(main.trimmingCharacters(in: .whitespacesAndNewlines).dropLast(1))
        )

        if isNotLegacy, let templates {
            result.append(##""templates": \##(templates)"##)
        }

        if isNotLegacy, let navigators {
            let navigators = navigators.map { ##""\##($0.key)":\##($0.value)"## }.joined(separator: ",\n")
            result.append(##""navigators": {\##(navigators)}"##)
        }

        let screens: String = contents.map { content in
            switch content {
            case let .screen(name, value):
                ##""\##(name)":\##(value)"##
            case let .element(name, value):
                if isNotLegacy {
                    ##""\##(name)": { "content": \##(value)}"##
                } else {
                    ##""\##(name)": { "background": "#000000FF", "content": \##(value)}"##
                }
            }
        }.joined(separator: ",\n")

        if isNotLegacy {
            result.append(##""screens": {\##(screens)}"##)
        } else {
            result.append(##""styles": {\##(screens)}"##)
        }

        if isNotLegacy {
            var script = script ?? ""
            if let startScreenName {
                script += Schema.LegacyScripts.legacyOpenDefaultScreen(screenId: startScreenName)
            }

            guard let encodedScript = try String(data: JSONEncoder().encode(script), encoding: .utf8) else {
                throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Script Corrupted"))
            }

            result.append(##""script": \##(encodedScript)"##)
        }

        return result.joined(separator: ",\n") + "\n}"
    }
}
