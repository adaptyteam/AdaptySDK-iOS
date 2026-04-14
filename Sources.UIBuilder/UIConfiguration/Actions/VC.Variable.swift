//
//  VC.Variable.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 14.01.2026.
//

import Foundation

extension VC {
    struct Variable: Sendable, Hashable {
        let path: [String]
        let setter: String?
        let scope: Scope
        let converter: (any Converter)?

        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.path == rhs.path
                && lhs.setter == rhs.setter
                && lhs.scope == rhs.scope
                && {
                    switch (lhs.converter, rhs.converter) {
                    case (nil, nil):
                        true
                    case let (lhs?, rhs?):
                        lhs.isEqual(to: rhs)
                    default:
                        false
                    }
                }()
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(path)
            hasher.combine(setter)
            hasher.combine(scope)
            hasher.combine(converter == nil)
            if let converter {
                hasher.combine(ObjectIdentifier(type(of: converter)))
                converter.hash(into: &hasher)
            }
        }
    }
}

extension VC.Variable {
    func pathWithScreenContext(_ contextPath: [String]) -> [String] {
        if scope == .screen, !contextPath.isEmpty {
            contextPath + path
        } else {
            path
        }
    }
}
