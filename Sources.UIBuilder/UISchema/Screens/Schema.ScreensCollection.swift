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

        let legacyBottomSheetNavigator = legacyBottomSheetNavigator()
        return [
            legacyDefaultNavigator.id: legacyDefaultNavigator,
            legacyBottomSheetNavigator.id: legacyBottomSheetNavigator
        ]
    }

    func legacyBottomSheetNavigator() -> Schema.Navigator {
        let navigatorId = "legacy-bottom-sheet"
        let navigatorBackground = Schema.AssetReference.color(.init(customId: nil, data: 0x00000066))
        let clearBackground = Schema.AssetReference.color(.init(customId: nil, data: 0x00000000))

        let onAppear = Schema.Navigator.AppearanceTransition(
            background: .init(
                timeline: .init(
                    duration: 300,
                    interpolator: .linear,
                    startDelay: 0,
                    loop: nil,
                    loopDelay: 0,
                    pingPongDelay: 0,
                    loopCount: nil
                ),
                range: .init(
                    start: clearBackground,
                    end: navigatorBackground
                )
            ),
            content: [.offset(
                .init(
                    duration: 350,
                    interpolator: .easeIn,
                    startDelay: 0,
                    loop: nil,
                    loopDelay: 0,
                    pingPongDelay: 0,
                    loopCount: nil
                ),
                .init(
                    start: .init(x: .zero, y: .screen(1)),
                    end: .zero
                )
            )]
        )
        let onDisappear = Schema.Navigator.AppearanceTransition(
            background: .init(
                timeline: .init(
                    duration: 300,
                    interpolator: .linear,
                    startDelay: 0,
                    loop: nil,
                    loopDelay: 0,
                    pingPongDelay: 0,
                    loopCount: nil
                ),
                range: .init(
                    start: navigatorBackground,
                    end: clearBackground
                )
            ),
            content: [.offset(
                .init(
                    duration: 350,
                    interpolator: .linear,
                    startDelay: 0,
                    loop: nil,
                    loopDelay: 0,
                    pingPongDelay: 0,
                    loopCount: nil
                ),
                .init(
                    start: .zero,
                    end: .init(x: .zero, y: .screen(1))
                )
            )]
        )

        return Schema.Navigator(
            id: navigatorId,
            background: navigatorBackground,
            content: .box(.init(
                width: .fillMax,
                height: .fillMax,
                horizontalAlignment: .center,
                verticalAlignment: .bottom,
                content: .scrrenHolder
            ), nil),
            order: Schema.Navigator.default.order + 100,
            appearances: [
                VC.Navigator.AppearanceTransition.onAppearKey: onAppear,
                VC.Navigator.AppearanceTransition.onDisappearKey: onDisappear
            ],
            transitions: nil,
            defaultScreenActions: .init(
                onOutsideTap: [.init(
                    path: ["SDK", "closeScreen"],
                    params: [
                        "navigatorId": .string(navigatorId),
                        "transitionId": .string(VC.Navigator.AppearanceTransition.onDisappearKey)
                    ],
                    scope: .global
                )],
                onSystemBack: nil
            )
        )
    }
}
