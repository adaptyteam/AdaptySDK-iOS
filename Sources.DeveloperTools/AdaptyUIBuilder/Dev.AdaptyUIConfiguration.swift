//
//  AdaptyViewConfigurationTestWrapper.swift
//  AdaptyDeveloperTools
//
//  Created by Aleksey Goncharov on 20.05.2024.
//

import AdaptyUIBuider

@available(*, deprecated, renamed: "Dev.AdaptyUIConfiguration")
public struct AdaptyViewConfigurationTestWrapper {
    var wrapped: AdaptyUIConfiguration

    @available(*, deprecated, renamed: "wrapped")
    var value: AdaptyUIConfiguration { wrapped }

#if DEBUG
    static func create(
        templateId: String = "basic",
        locale: String = "en",
        isRightToLeft: Bool = false,
        content: String
    ) throws -> Self {
        try .init(wrapped:
            Dev.AdaptyUIConfiguration.create(
                templateId: templateId,
                locale: locale,
                isRightToLeft: isRightToLeft,
                content: content
            ).wrapped
        )
    }
#endif
}

public extension Dev {
    struct AdaptyUIConfiguration {
        typealias Wrapped = AdaptyUIBuider.AdaptyUIConfiguration
        let wrapped: Wrapped
    }
}

#if DEBUG
public extension Dev.AdaptyUIConfiguration {
    static func create(
        templateId: String = "basic",
        locale: String = "en",
        isRightToLeft: Bool = false,
        content: String
    ) throws -> Self {
        let configuration = try AdaptyUIConfiguration.create(
            templateId: templateId,
            locale: locale,
            isRightToLeft: isRightToLeft,
            images: [
                "star.fill", "beagle", "close", "coast-bg",
            ],
            colors: [
                "$green_figma": .solidColor(.create(data: 0x3EBD78FF)),
                "$green_figma_cc": .solidColor(.create(data: 0x3EBD78CC)),
                "$black20": .solidColor(.create(data: 0x01010138)),
                "$black80": .solidColor(.create(data: 0x010101CC)),
                "$black": .solidColor(.create(data: 0x000000FF)),
                "$black@dark": .solidColor(.create(data: 0xFFFFFFFF)),
                "$white": .solidColor(.create(data: 0xFFFFFFFF)),
                "$white@dark": .solidColor(.create(data: 0x000000FF)),
                "$red": .solidColor(.create(data: 0xFF0000FF)),
                "$red_2": .solidColor(.create(data: 0xF3227AFF)),
                "$red_2_transparent": .solidColor(.create(data: 0xF3227A44)),
                "$green": .solidColor(.create(data: 0x00FF00FF)),
                "$blue": .solidColor(.create(data: 0x0000FFFF)),
                "$light": .solidColor(.create(data: 0xF4D13BFF)),
                "$red_to_transparent_top_to_bottom": .colorGradient(.create(
                    kind: .linear,
                    start: .create(x: 0.5, y: 0.0),
                    end: .create(x: 0.5, y: 1.0),
                    items: [
                        .create(color: .create(data: 0xFF000099), p: 0.0),
                        .create(color: .create(data: 0xFF000000), p: 1.0),
                    ]
                )),
                "$blue_to_transparent_top_to_bottom": .colorGradient(.create(
                    kind: .linear,
                    start: .create(x: 0.5, y: 0.0),
                    end: .create(x: 0.5, y: 1.0),
                    items: [
                        .create(color: .create(data: 0x0000FF99), p: 0.0),
                        .create(color: .create(data: 0x0000FF00), p: 1.0),
                    ]
                )),
                "$green_to_transparent_top_to_bottom": .colorGradient(.create(
                    kind: .linear,
                    start: .create(x: 0.5, y: 0.0),
                    end: .create(x: 0.5, y: 1.0),
                    items: [
                        .create(color: .create(data: 0x00FF0099), p: 0.0),
                        .create(color: .create(data: 0x00FF0000), p: 1.0),
                    ]
                )),
                "$yellow_to_purple_top_to_bottom": .colorGradient(.create(
                    kind: .linear,
                    start: .create(x: 0.5, y: 0.0),
                    end: .create(x: 0.5, y: 1.0),
                    items: [
                        .create(color: .create(data: 0xF9B61AFF), p: 0.0),
                        .create(color: .create(data: 0x8A4DECFF), p: 1.0),
                    ]
                )),
                "$pink_to_red_top_to_bottom": .colorGradient(.create(
                    kind: .linear,
                    start: .create(x: 0.5, y: 0.0),
                    end: .create(x: 0.5, y: 1.0),
                    items: [
                        .create(color: .create(data: 0xB577BFFF), p: 0.0),
                        .create(color: .create(data: 0xF3227AFF), p: 1.0),
                    ]
                )),
                "$shimmer_gradient": .colorGradient(.create(
                    kind: .linear,
                    start: .create(x: 0.0, y: 1.0),
                    end: .create(x: 1.0, y: 0.0),
                    items: [
                        .create(color: .create(data: 0xFFFFFF00), p: 0.0),
                        .create(color: .create(data: 0xFFFFFF00), p: 0.35),
                        .create(color: .create(data: 0xFFFFFFFF), p: 0.5),
                        .create(color: .create(data: 0xFFFFFF00), p: 0.65),
                        .create(color: .create(data: 0xFFFFFF00), p: 1.0),
                    ]
                )),
            ],
            strings: [
                "$short": ["Article."],
                "$medium": ["Article nor prepare chicken you him now."],
                "$long": ["Article nor prepare chicken you him now. Shy merits say advice ten before lovers innate add. "],
                "$timer_basic": ["#TIMER_Total_Days_1", "d ", "#TIMER_hh", ":", "#TIMER_mm", ":", "#TIMER_ss"],
                "$countdown": ["#TIMER_Total_Seconds_1"],
                "$card_title": ["Before this app I wasn't able to do anything by myself. Now I am, wow! Highly recommend!"],
                "$card_subtitle": ["App Store review"],
                "$footer_restore": ["Restore Purchases"],
                "$footer_terms": ["Terms & Conditions"],
                "$footer_privacy": ["Privacy Policy"],
                "$footer_support": ["Support"],

                "$product_title_1": ["Weekly"],
                "$product_title_2": ["Offer Text"],
                "$product_title_3": ["$99.99"],
                "$product_title_4": ["$9.99 / week"],

                "$string_section_button_a": ["Section A"],
                "$section_a_title": ["Selected Section A Content"],
                "$string_section_button_b": ["Section B"],
                "$section_b_title": ["Selected Section B Content"],
            ],
            content: content
        )

        return .init(wrapped: configuration)
    }
}
#endif
