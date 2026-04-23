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
        let converter: AnyConverter?
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

