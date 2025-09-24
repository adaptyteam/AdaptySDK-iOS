//
//  VC.EdgeInsets.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

package extension VC {
    struct EdgeInsets: Sendable, Hashable {
        package static let zero = VC.EdgeInsets(same: .point(0.0))
        static let defaultValue: VC.Unit = .point(0.0)

        package let leading: VC.Unit
        package let top: VC.Unit
        package let trailing: VC.Unit
        package let bottom: VC.Unit
    }
}

#if DEBUG
package extension VC.EdgeInsets {
    static func create(
        same: VC.Unit = defaultValue
    ) -> Self {
        .init(same: same)
    }

    static func create(
        leading: VC.Unit = defaultValue,
        top: VC.Unit = defaultValue,
        trailing: VC.Unit = defaultValue,
        bottom: VC.Unit = defaultValue
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

extension VC.EdgeInsets {
    init(same: VC.Unit) {
        self.init(leading: same, top: same, trailing: same, bottom: same)
    }

    package var isZero: Bool {
        leading.isZero && top.isZero && trailing.isZero && bottom.isZero
    }
}

extension VC.EdgeInsets: Codable {
    enum CodingKeys: String, CodingKey {
        case top
        case leading
        case trailing
        case bottom
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let defaultValue = Self.defaultValue
        if let value = try? container.decode(VC.Unit.self) {
            self.init(same: value)
        } else if let values = try? container.decode([VC.Unit].self) {
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
                leading: container.decodeIfPresent(VC.Unit.self, forKey: .leading) ?? defaultValue,
                top: container.decodeIfPresent(VC.Unit.self, forKey: .top) ?? defaultValue,
                trailing: container.decodeIfPresent(VC.Unit.self, forKey: .trailing) ?? defaultValue,
                bottom: container.decodeIfPresent(VC.Unit.self, forKey: .bottom) ?? defaultValue
            )
        }
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if case let .point(value) = leading, value == 0 {} else
        { try container.encode(leading, forKey: .leading) }

        if case let .point(value) = top, value == 0 {} else
        { try container.encode(leading, forKey: .top) }

        if case let .point(value) = trailing, value == 0 {} else
        { try container.encode(leading, forKey: .trailing) }

        if case let .point(value) = bottom, value == 0 {} else
        { try container.encode(leading, forKey: .bottom) }
    }
}
