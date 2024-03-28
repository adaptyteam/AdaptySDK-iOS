//
//  VC.Button.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct Button {
        let shape: Decorator?
        let selectedShape: Decorator?
        let title: Text?
        let selectedTitle: Text?
        let align: AdaptyUI.OldButton.Align?
        let action: AdaptyUI.ButtonAction?
        let visibility: Bool
        let transitionIn: [AdaptyUI.Transition]
    }
}

extension AdaptyUI.ViewConfiguration.Button: Decodable {
    enum CodingKeys: String, CodingKey {
        case shape
        case selectedShape = "selected_shape"
        case selectedTitle = "selected_title"
        case title
        case align
        case action
        case visibility
        case transitionIn = "transition_in"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        shape = try container.decodeIfPresent(AdaptyUI.ViewConfiguration.Decorator.self, forKey: .shape)
        selectedShape = try container.decodeIfPresent(AdaptyUI.ViewConfiguration.Decorator.self, forKey: .selectedShape)
        selectedTitle = try container.decodeIfPresent(AdaptyUI.ViewConfiguration.Text.self, forKey: .selectedTitle)
        title = try container.decodeIfPresent(AdaptyUI.ViewConfiguration.Text.self, forKey: .title)
        align = try container.decodeIfPresent(AdaptyUI.OldButton.Align.self, forKey: .align)
        action = try container.decodeIfPresent(AdaptyUI.ButtonAction.self, forKey: .action)
        visibility = try container.decodeIfPresent(Bool.self, forKey: .visibility) ?? true

        if let array = try? container.decodeIfPresent([AdaptyUI.Transition].self, forKey: .transitionIn) {
            transitionIn = array
        } else if let union = try? container.decodeIfPresent(AdaptyUI.TransitionUnion.self, forKey: .transitionIn) {
            transitionIn = union.items
        } else if let transition = try container.decodeIfPresent(AdaptyUI.Transition.self, forKey: .transitionIn) {
            transitionIn = [transition]
        } else {
            transitionIn = []
        }
    }
}
