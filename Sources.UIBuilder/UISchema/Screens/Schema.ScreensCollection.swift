//
//  Schema.ScreensCollection.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 05.12.2025.
//

import Foundation

extension Schema {
    struct ScreensCollection: Sendable, Hashable {
        let screens: [ScreenType: Screen]
        let legacyGeneratedNavigators: [NavigatorIdentifier: Navigator]?
    }
}

extension Schema.ScreensCollection: DecodableWithConfiguration {
    init(from decoder: any Decoder, configuration: Schema.DecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)
        var nestedConfiguration = configuration

        var screens = [String: Schema.Screen]()
        screens.reserveCapacity(container.allKeys.count)
        try container.allKeys.forEach { key in
            nestedConfiguration.insideScreenId = key.stringValue
            let value = try container.decode(Schema.Screen.self, forKey: key, configuration: nestedConfiguration)
            screens[value.id] = value
        }

        if configuration.isLegacy {
            try self.init(
                screens: screens,
                legacyGeneratedNavigators: decoder.legacyGenerateNavigators(configuration: configuration)
            )
        } else {
            self.init(
                screens: screens,
                legacyGeneratedNavigators: nil
            )
        }
    }
}

private let legacyScreenCodingKey = AnyCodingKey("default")

private enum LegacyScreenCodingKeys: String, CodingKey {
    case background
    case overlay
}

private extension Decoder {
    func legacyGenerateNavigators(
        configuration: Schema.DecodingConfiguration
    ) throws -> [Schema.NavigatorIdentifier: Schema.Navigator] {
        let container = try container(keyedBy: AnyCodingKey.self)

        let defaultScreenId = "default"
        let legacyScreen = try container.nestedContainer(keyedBy: LegacyScreenCodingKeys.self, forKey: AnyCodingKey(defaultScreenId))
        var nestedConfiguration = configuration
        nestedConfiguration.insideScreenId = defaultScreenId

        let content: Schema.Element =
            if let overlay = try legacyScreen.decodeIfPresent(Schema.Element.self, forKey: .overlay, configuration: nestedConfiguration) {
                .stack(.init(
                    type: .z,
                    horizontalAlignment: .center,
                    verticalAlignment: .bottom,
                    spacing: 0,
                    items: [
                        .element(.scrrenHolder),
                        .element(overlay)
                    ]
                ), nil)
            } else {
                .scrrenHolder
            }

        let legacyDefaultNavigator = try Schema.Navigator(
            id: Schema.Navigator.default.id,
            background: legacyScreen.decode(Schema.AssetReference.self, forKey: .background),
            content: content,
            order: Schema.Navigator.default.order,
            appearances: nil,
            transitions: nil,
            defaultScreenActions: .empty
        )

        guard container.allKeys.count > 1 else {
            return [legacyDefaultNavigator.id: legacyDefaultNavigator]
        }

        let legacyBottomSheetNavigator = Schema.Navigator(
            id: "legacy-bottom-sheet",
            background: .color(.transparent), // TODO: ???
            content: .scrrenHolder,
            order: Schema.Navigator.default.order + 100,
            appearances: nil, // TODO: ???
            transitions: nil, // TODO: ???
            defaultScreenActions: .empty // TODO: ???
        )

        return [
            legacyDefaultNavigator.id: legacyDefaultNavigator,
            legacyBottomSheetNavigator.id: legacyBottomSheetNavigator
        ]
    }
}
