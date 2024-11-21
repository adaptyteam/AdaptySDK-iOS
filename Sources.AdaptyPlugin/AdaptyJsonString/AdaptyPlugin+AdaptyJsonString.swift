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

    @objc static func execute(
        withJsonString jsonString: AdaptyJsonString,
        _ completion: @escaping AdaptyJsonDataCompletion
    ) {
        execute(withJsonData: jsonString.asAdaptyJsonData, completion)
    }

    @objc static func execute(
        method: String,
        withJsonString jsonString: AdaptyJsonString,
        _ completion: @escaping AdaptyJsonDataCompletion
    ) {
        execute(method: method, withJsonData: jsonString.asAdaptyJsonData, completion)
    }
}
