//
//  EdgeInsets.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

package extension AdaptyViewConfiguration {
    struct EdgeInsets: Sendable, Hashable {
        package static let zero = AdaptyViewConfiguration.EdgeInsets(same: .point(0.0))
        static let defaultValue: AdaptyViewConfiguration.Unit = .point(0.0)

        package let leading: AdaptyViewConfiguration.Unit
        package let top: AdaptyViewConfiguration.Unit
        package let trailing: AdaptyViewConfiguration.Unit
        package let bottom: AdaptyViewConfiguration.Unit
    }
}

#if DEBUG
    package extension AdaptyViewConfiguration.EdgeInsets {
        static func create(
            same: AdaptyViewConfiguration.Unit = defaultValue
        ) -> Self {
            .init(same: same)
        }

        static func create(
            leading: AdaptyViewConfiguration.Unit = defaultValue,
            top: AdaptyViewConfiguration.Unit = defaultValue,
            trailing: AdaptyViewConfiguration.Unit = defaultValue,
            bottom: AdaptyViewConfiguration.Unit = defaultValue
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

extension AdaptyViewConfiguration.EdgeInsets {
    init(same: AdaptyViewConfiguration.Unit) {
        self.init(leading: same, top: same, trailing: same, bottom: same)
    }

    package var isZero: Bool {
        leading.isZero && top.isZero && trailing.isZero && bottom.isZero
    }
}

extension AdaptyViewConfiguration.EdgeInsets: Codable {
    enum CodingKeys: String, CodingKey {
        case top
        case leading
        case trailing
        case bottom
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let defaultValue = Self.defaultValue
        if let value = try? container.decode(AdaptyViewConfiguration.Unit.self) {
            self.init(same: value)
        } else if let values = try? container.decode([AdaptyViewConfiguration.Unit].self) {
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
                leading: container.decodeIfPresent(AdaptyViewConfiguration.Unit.self, forKey: .leading) ?? defaultValue,
                top: container.decodeIfPresent(AdaptyViewConfiguration.Unit.self, forKey: .top) ?? defaultValue,
                trailing: container.decodeIfPresent(AdaptyViewConfiguration.Unit.self, forKey: .trailing) ?? defaultValue,
                bottom: container.decodeIfPresent(AdaptyViewConfiguration.Unit.self, forKey: .bottom) ?? defaultValue
            )
        }
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if case .point(let value) = leading, value == 0 {} else
        { try container.encode(leading, forKey: .leading) }

        if case .point(let value) = top, value == 0 {} else
        { try container.encode(leading, forKey: .top) }

        if case .point(let value) = trailing, value == 0 {} else
        { try container.encode(leading, forKey: .trailing) }

        if case .point(let value) = bottom, value == 0 {} else
        { try container.encode(leading, forKey: .bottom) }
    }
}
