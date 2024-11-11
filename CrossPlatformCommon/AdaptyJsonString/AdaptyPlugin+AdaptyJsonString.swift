//
//  AdaptyPlugin+AdaptyJsonString.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 07.11.2024.
//

import Foundation

public extension AdaptyPlugin {
    @inlinable
    static func execute(withJson jsonString: AdaptyJsonString) async -> AdaptyJsonData {
        await execute(withJson: jsonString.asAdaptyJsonData)
    }

    @inlinable
    static func execute(method: String, withJson jsonString: AdaptyJsonString) async -> AdaptyJsonData {
        await execute(method: method, withJson: jsonString.asAdaptyJsonData)
    }
}
