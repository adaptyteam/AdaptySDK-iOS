//
//  AdaptyOnboardingsStateUpdatedAction+Encodable.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 28.05.2025.
//

import AdaptyUI
import Foundation

extension AdaptyOnboardingsStateUpdatedAction: Encodable {
    enum CodingKeys: String, CodingKey {
        case elementId = "element_id"
        case elementType = "element_type"
        case value
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(elementId, forKey: .elementId)

        switch params {
        case .select(let value):
            try container.encode("select", forKey: .elementType)
            try container.encode(value, forKey: .value)

        case .multiSelect(let value):
            try container.encode("multi_select", forKey: .elementType)
            try container.encode(value, forKey: .value)

        case .input(let value):
            try container.encode("input", forKey: .elementType)
            try container.encode(value, forKey: .value)

        case .datePicker(let value):
            try container.encode("date_picker", forKey: .elementType)
            try container.encode(value, forKey: .value)
        }
    }
}
