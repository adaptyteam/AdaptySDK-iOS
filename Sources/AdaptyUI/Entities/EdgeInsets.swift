//
//  EdgeInsets.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

extension AdaptyUI {
    package struct EdgeInsets {
        package let leading: Double
        package let top: Double
        package let trailing: Double
        package let bottom: Double
    }
}

extension AdaptyUI.EdgeInsets {
    package static let zero = AdaptyUI.EdgeInsets(same: 0.0)
    package init(same value: Double) {
        self.init(leading: value, top: value, trailing: value, bottom: value)
    }

    package var isZero: Bool {
        leading == 0.0 && top == 0.0 && trailing == 0.0 && bottom == 0.0
    }

    package var isSame: Bool {
        (leading == top) && (trailing == bottom) && (leading == trailing)
    }
}

extension AdaptyUI.EdgeInsets: Decodable {
    enum CodingKeys: String, CodingKey {
        case top
        case leading
        case trailing
        case bottom
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Double.self) {
            self.init(same: value)
        } else if let values = try? container.decode([Double].self) {
            switch values.count {
            case 0: self.init(same: 0.0)
            case 1: self.init(same: values[0])
            case 2: self.init(leading: values[1], top: values[0], trailing: values[1], bottom: values[0])
            case 3: self.init(leading: values[0], top: values[1], trailing: values[2], bottom: 0.0)
            default: self.init(leading: values[0], top: values[1], trailing: values[2], bottom: values[3])
            }
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            try self.init(
                leading: container.decodeIfPresent(Double.self, forKey: .leading) ?? 0.0,
                top: container.decodeIfPresent(Double.self, forKey: .top) ?? 0.0,
                trailing: container.decodeIfPresent(Double.self, forKey: .trailing) ?? 0.0,
                bottom: container.decodeIfPresent(Double.self, forKey: .bottom) ?? 0.0
            )
        }
    }
}
