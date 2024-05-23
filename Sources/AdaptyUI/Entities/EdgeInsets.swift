//
//  EdgeInsets.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

extension AdaptyUI {
    package struct EdgeInsets {
        package static let zero = AdaptyUI.EdgeInsets(same: 0.0)
        static let defaultValue = 0.0
        
        package let leading: Double
        package let top: Double
        package let trailing: Double
        package let bottom: Double
    }
}

#if DEBUG
    package extension AdaptyUI.EdgeInsets {
        static func create(
            same: Double = defaultValue
        ) -> Self {
            .init(same: same)
        }

        static func create(
            leading: Double = defaultValue,
            top: Double = defaultValue,
            trailing: Double = defaultValue,
            bottom: Double = defaultValue
        ) -> Self {
            .init(
                leading: leading,
                top: top,
                trailing: trailing,
                bottom: bottom
            )
        }
    }
#endif

extension AdaptyUI.EdgeInsets {
    package static let zero1 = AdaptyUI.EdgeInsets(same: defaultValue)

    init(same: Double) {
        self.init(leading: same, top: same, trailing: same, bottom: same)
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
        let defaultValue = Self.defaultValue
        if let value = try? container.decode(Double.self) {
            self.init(same: value)
        } else if let values = try? container.decode([Double].self) {
            switch values.count {
            case 0: self.init(same: defaultValue)
            case 1: self.init(same: values[0])
            case 2: self.init(leading: values[1], top: values[0], trailing: values[1], bottom: values[0])
            case 3: self.init(leading: values[0], top: values[1], trailing: values[2], bottom: defaultValue)
            default: self.init(leading: values[0], top: values[1], trailing: values[2], bottom: values[3])
            }
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            try self.init(
                leading: container.decodeIfPresent(Double.self, forKey: .leading) ?? defaultValue,
                top: container.decodeIfPresent(Double.self, forKey: .top) ?? defaultValue,
                trailing: container.decodeIfPresent(Double.self, forKey: .trailing) ?? defaultValue,
                bottom: container.decodeIfPresent(Double.self, forKey: .bottom) ?? defaultValue
            )
        }
    }
}
