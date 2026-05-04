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
        let params: [String: VC.AnyValue]?
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

    var isSDK: Bool {
        scope == .global && path.first == "SDK"
    }

    func paramsAsDictionary() -> [AnyHashable: Any]? {
        params?.asObject
    }
}

