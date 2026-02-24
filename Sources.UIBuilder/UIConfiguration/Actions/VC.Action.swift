//
//  VC.Action.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 03.07.2023
//

import Foundation

package extension VC {
    struct Action: Sendable, Hashable {
        let path: [String]
        let params: Constants?
        let scope: Scope
    }
}

extension VC.Action {
    func pathWithScreenContext(_ contextPath: [String]) -> [String] {
        if scope == .screen, !contextPath.isEmpty {
            contextPath + path
        } else {
            path
        }
    }
}
