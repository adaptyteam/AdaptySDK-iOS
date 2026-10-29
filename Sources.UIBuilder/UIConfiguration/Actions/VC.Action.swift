//
//  VC.Action.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 03.07.2023
//

import Foundation

package extension VC {
    struct Action: Sendable {
        let path: [String]
        let params: [String: VC.Value]?
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

    @inlinable
    var sdkMethod: String? {
       guard scope == .global,
             path.count == 2,
             path[0] == "SDK"
        else { return nil }
        return path[1]
    }
}

