//
//  AdaptyPlugin+AdaptyJsonString.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 07.11.2024.
//

import Adapty
import Foundation

public extension AdaptyPlugin {
    @inlinable
    static func request(json jsonString: AdaptyJsonString) async -> AdaptyJsonData {
        await request(json: jsonString.asAdaptyJsonData)
    }

    @inlinable
    static func request(method: String, json jsonString: AdaptyJsonString) async -> AdaptyJsonData {
        await request(method: method, json: jsonString.asAdaptyJsonData)
    }
}
