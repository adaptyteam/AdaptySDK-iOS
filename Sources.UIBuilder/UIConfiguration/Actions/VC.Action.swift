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
        let params: [String: Parameter]?
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

    // TODO: refactor
    func paramsWithScreenInstance(_ instance: VS.ScreenInstance) -> [String: Parameter] {
        guard var params, params.isNotEmpty else {
            return [
                "screenInstanceId": .string(instance.id),
                "screenContextPath": .string(instance.contextPath.joined(separator: "."))
            ]
        }

        params["screenInstanceId"] = .string(instance.id)
        params["screenContextPath"] = .string(instance.contextPath.joined(separator: "."))

        return params
    }
}
