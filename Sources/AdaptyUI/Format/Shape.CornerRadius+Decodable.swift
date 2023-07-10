//
//  Shape.CornerRadius+Decodable.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 03.07.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI.Shape.CornerRadius: Decodable {
    struct Object: Decodable {
        let topLeft: Double?
        let topRight: Double?
        let bottomRight: Double?
        let bottomLeft: Double?

        enum CodingKeys: String, CodingKey {
            case topLeft = "tl"
            case topRight = "tr"
            case bottomRight = "br"
            case bottomLeft = "bl"
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Double.self) {
            self = .same(value)
        } else if let values = try? container.decode([Double].self) {
            switch values.count {
            case 0: self = .none
            case 1: self = .same(values[0])
            case 2: self = .different(topLeft: values[0], topRight: values[1], bottomRight: 0.0, bottomLeft: 0.0)
            case 3: self = .different(topLeft: values[0], topRight: values[1], bottomRight: values[2], bottomLeft: 0.0)
            default: self = .different(topLeft: values[0], topRight: values[1], bottomRight: values[2], bottomLeft: values[3])
            }
        } else if let value = try? container.decode(Object.self) {
            self = .different(
                topLeft: value.topLeft ?? 0.0,
                topRight: value.topRight ?? 0.0,
                bottomRight: value.bottomRight ?? 0.0,
                bottomLeft: value.bottomLeft ?? 0.0
            )
        } else {
            self = .none
        }
    }
}
