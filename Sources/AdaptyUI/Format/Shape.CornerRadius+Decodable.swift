//
//  Shape.CornerRadius+Decodable.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 03.07.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI.Shape.CornerRadius: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Double.self) {
            self = .same(value)
        } else if let values = try? container.decode([Double].self) {
            if values.isEmpty {
                self = .none
            } else if values.count < 4 {
                self = .same(values[0])
            } else {
                self = .different(topLeft: values[0], topRight: values[1], bottomRight: values[2], bottomLeft: values[3])
            }
        } else {
            self = .none
        }
    }
}
