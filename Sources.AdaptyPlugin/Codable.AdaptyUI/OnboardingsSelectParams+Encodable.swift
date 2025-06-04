//
//  OnboardingsSelectParams+Encodable.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 28.05.2025.
//

import AdaptyUI
import Foundation

extension OnboardingsSelectParams: Encodable {
    enum CodingKeys: String, CodingKey {
        case id
        case value
        case label
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(value, forKey: .value)
        try container.encode(label, forKey: .label)
    }
}
