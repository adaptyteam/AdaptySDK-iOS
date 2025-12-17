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

#if DEBUG
public extension Dev_AdaptyUIConfiguration {
    static let `default` = (
        assets: """
        [
            { "type":"image", "id":"star.fill", "custom_id":"star.fill", "url":"https://unknown.image.com" },
            { "type":"image", "id":"beagle", "custom_id":"beagle", "url":"https://unknown.image.com" },
            { "type":"image", "id":"close", "custom_id":"close", "url":"https://unknown.image.com" },
            { "type":"image", "id":"coast-bg", "custom_id":"coast-bg", "url":"https://unknown.image.com" },
            { "type":"color", "id":"$green_figma", "value": "#3EBD78FF"},
            { "type":"color", "id":"$green_figma_cc", "value": "#3EBD78CC"},
            { "type":"color", "id":"$black20", "value": "#01010138"},
            { "type":"color", "id":"$black80", "value": "#010101CC"},
            { "type":"color", "id":"$black", "value": "#000000FF"},
            { "type":"color", "id":"$black@dark", "value": "#FFFFFFFF"},
            { "type":"color", "id":"$white", "value": "#FFFFFFFF"},
            { "type":"color", "id":"$white@dark", "value": "#000000FF"},
            { "type":"color", "id":"$red", "value": "#FF0000FF"},
            { "type":"color", "id":"$red_2", "value": "#F3227AFF"},
            { "type":"color", "id":"$red_2_transparent", "value": "#F3227A44"},
            { "type":"color", "id":"$green", "value": "#00FF00FF"},
            { "type":"color", "id":"$blue", "value": "#0000FFFF"},
            { "type":"color", "id":"$light", "value": "#F4D13BFF"},
            { "type":"linear-gradient", "id":"$red_to_transparent_top_to_bottom", "values": [
                    { "color": "#FF000099", "p": 0 },
                    { "color": "#FF000000", "p": 1 }
            ], "points": { "x0": 0.5, "y0": 0, "x1": 0.5, "y1": 1}},
            { "type":"linear-gradient", "id":"$blue_to_transparent_top_to_bottom", "values": [
                    { "color": "#0000FF99", "p": 0 },
                    { "color": "#0000FF00", "p": 1 }
            ], "points": { "x0": 0.5, "y0": 0, "x1": 0.5, "y1": 1}},
            { "type":"linear-gradient", "id":"$green_to_transparent_top_to_bottom", "values": [
                    { "color": "#00FF0099", "p": 0 },
                    { "color": "#00FF0000", "p": 1 }
            ], "points": { "x0": 0.5, "y0": 0, "x1": 0.5, "y1": 1}},
            { "type":"linear-gradient", "id":"$yellow_to_purple_top_to_bottom", "values": [
                    { "color": "#F9B61AFF", "p": 0 },
                    { "color": "#8A4DECFF", "p": 1 }
            ], "points": { "x0": 0.5, "y0": 0, "x1": 0.5, "y1": 1}},
            { "type":"linear-gradient", "id":"$pink_to_red_top_to_bottom", "values": [
                    { "color": "#B577BFFF", "p": 0 },
                    { "color": "#F3227AFF", "p": 1 }
            ], "points": { "x0": 0.5, "y0": 0, "x1": 0.5, "y1": 1}},
            { "type":"linear-gradient", "id":"$shimmer_gradient", "values": [
                    { "color": "#FFFFFF00", "p": 0 },
                    { "color": "#FFFFFF00", "p": 0.35 },
                    { "color": "#FFFFFFFF", "p": 0.5 },
                    { "color": "#FFFFFF00", "p": 0.65 },
                    { "color": "#FFFFFF00", "p": 1 }
            ], "points": { "x0": 0, "y0": 1, "x1": 1, "y1": 0}}
        ]
        """,
        localization: """
        {
            "id": "en",
            "is_right_to_left": false,
            "strings": [
                { "id": "$short", "value": "Article." },
                { "id": "$medium", "value": "Article nor prepare chicken you him now." },
                { "id": "$long", "value": "Article nor prepare chicken you him now. Shy merits say advice ten before lovers innate add." },
                { "id": "$timer_basic", "value": [
                        {"tag": "TIMER_Total_Days_1"}, 
                        {"text": "d "}, 
                        {"tag": "TIMER_hh"}, 
                        {"text": ":"},
                        {"tag": "TIMER_mm"}, 
                        {"text": ":"},
                        {"tag": "TIMER_ss"}
                ]},
                { "id": "$countdown", "value": {"tag": "TIMER_Total_Seconds_1"}},
                { "id": "$card_title", "value": "Before this app I wasn't able to do anything by myself. Now I am, wow! Highly recommend!" },
                { "id": "$card_subtitle", "value": "App Store review" },
                { "id": "$footer_restore", "value": "Restore Purchases" },
                { "id": "$footer_terms", "value": "Terms & Conditions." },
                { "id": "$footer_privacy", "value": "Privacy Policy" },
                { "id": "$footer_support", "value": "Support" },
                { "id": "$product_title_1", "value": "Weekly" },
                { "id": "$product_title_2", "value": "Offer Text"},
                { "id": "$product_title_3", "value": "$99.99"},
                { "id": "$product_title_4", "value": "$9.99 / week"},
                { "id": "$string_section_button_a", "value": "Section A"},
                { "id": "$section_a_title", "value": "Selected Section A Content"},
                { "id": "$string_section_button_b", "value": "Section B"},
                { "id": "$section_b_title", "value": "Selected Section B Content"}
            ]
        }
        """,
        templates: String?.none,
        templateId: "basic"
    )

    static func create(
        templateId: String = Self.default.templateId,
        assets: String = Self.default.assets,
        localization: String = Self.default.localization,
        templates: String? = Self.default.templates,
        content: String
    ) throws -> Self {
        let configuration = try AdaptyUIConfiguration.create(
            templateId: templateId,
            assets: assets,
            localization: localization,
            templates: templates,
            content: content
        )
        return .init(wrapped: configuration)
    }
}
#endif
