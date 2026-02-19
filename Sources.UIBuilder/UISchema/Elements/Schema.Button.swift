//
//  Schema.Button.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    struct Button: Sendable, Hashable {
        let actions: [Schema.Action]
        let normalState: Schema.Element
        let selectedState: Schema.Element?
        let selectedCondition: Schema.StateCondition?
    }
}

extension Schema.Localizer {
    func button(_ from: Schema.Button) throws -> VC.Button {
        try .init(
            actions: from.actions,
            normalState: element(from.normalState),
            selectedState: from.selectedState.map(element),
            selectedCondition: from.selectedCondition
        )
    }
}

extension Schema.Button: DecodableWithConfiguration {
    enum CodingKeys: String, CodingKey {
        case actions = "action"
        case normalState = "normal"
        case selectedState = "selected"
        case selectedCondition = "selected_condition"
    }

    init(from decoder: Decoder, configuration: Schema.DecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            actions: container.decodeActions(forKey: .actions),
            normalState: container.decode(Schema.Element.self, forKey: .normalState, configuration: configuration),
            selectedState: container.decodeIfPresent(Schema.Element.self, forKey: .selectedState, configuration: configuration),
            selectedCondition: container.decodeIfPresent(Schema.StateCondition.self, forKey: .selectedCondition)
        )
    }
}
