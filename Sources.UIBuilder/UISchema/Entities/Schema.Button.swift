//
//  Schema.Button.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    struct Button: Sendable {
        let actions: [Schema.Action]
        let normalState: Schema.Element
        let selectedState: Schema.Element?
        let selectedCondition: VC.StateCondition?
    }
}

extension Schema.Localizer {
    func button(_ from: Schema.Button) throws -> VC.Button {
        try .init(
            actions: from.actions.map(action),
            normalState: element(from.normalState),
            selectedState: from.selectedState.map(element),
            selectedCondition: from.selectedCondition
        )
    }

    func buttonAction(_ from: VC.Action) -> VC.Action {
        guard case let .openUrl(stringId) = from else { return from }
        return .openUrl(urlIfPresent(stringId))
    }
}

extension Schema.Button: Decodable {
    enum CodingKeys: String, CodingKey {
        case actions = "action"
        case normalState = "normal"
        case selectedState = "selected"
        case selectedCondition = "selected_condition"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let actions =
            if let action = try? container.decode(Schema.Action.self, forKey: .actions) {
                [action]
            } else {
                try container.decode([Schema.Action].self, forKey: .actions)
            }
        try self.init(
            actions: actions,
            normalState: container.decode(Schema.Element.self, forKey: .normalState),
            selectedState: container.decodeIfPresent(Schema.Element.self, forKey: .selectedState),
            selectedCondition: container.decodeIfPresent(VC.StateCondition.self, forKey: .selectedCondition)
        )
    }
}
