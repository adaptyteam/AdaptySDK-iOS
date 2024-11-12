//
//  EdgeInsets.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

extension AdaptyUICore {
    package struct EdgeInsets: Sendable, Hashable {
        package static let zero = AdaptyUICore.EdgeInsets(same: .point(0.0))
        static let defaultValue: AdaptyUICore.Unit = .point(0.0)

        package let leading: AdaptyUICore.Unit
        package let top: AdaptyUICore.Unit
        package let trailing: AdaptyUICore.Unit
        package let bottom: AdaptyUICore.Unit
    }
}

#if DEBUG
    package extension AdaptyUICore.EdgeInsets {
        static func create(
            same: AdaptyUICore.Unit = defaultValue
        ) -> Self {
            .init(same: same)
        }

        static func create(
            leading: AdaptyUICore.Unit = defaultValue,
            top: AdaptyUICore.Unit = defaultValue,
            trailing: AdaptyUICore.Unit = defaultValue,
            bottom: AdaptyUICore.Unit = defaultValue
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

extension AdaptyUICore.EdgeInsets {
    init(same: AdaptyUICore.Unit) {
        self.init(leading: same, top: same, trailing: same, bottom: same)
    }

    package var isZero: Bool {
        leading.isZero && top.isZero && trailing.isZero && bottom.isZero
    }
}

extension AdaptyUICore.EdgeInsets: Decodable {
    enum CodingKeys: String, CodingKey {
        case top
        case leading
        case trailing
        case bottom
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let defaultValue = Self.defaultValue
        if let value = try? container.decode(AdaptyUICore.Unit.self) {
            self.init(same: value)
        } else if let values = try? container.decode([AdaptyUICore.Unit].self) {
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
                leading: container.decodeIfPresent(AdaptyUICore.Unit.self, forKey: .leading) ?? defaultValue,
                top: container.decodeIfPresent(AdaptyUICore.Unit.self, forKey: .top) ?? defaultValue,
                trailing: container.decodeIfPresent(AdaptyUICore.Unit.self, forKey: .trailing) ?? defaultValue,
                bottom: container.decodeIfPresent(AdaptyUICore.Unit.self, forKey: .bottom) ?? defaultValue
            )
        }
    }
}
