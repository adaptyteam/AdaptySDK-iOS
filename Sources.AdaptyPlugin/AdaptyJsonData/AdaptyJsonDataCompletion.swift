//
//  AdaptyJsonDataCompletion.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import Foundation

public typealias AdaptyJsonDataCompletion = @Sendable (AdaptyJsonData) -> Void

public extension AdaptyPlugin {
    @objc static func execute(
        withJsonData jsonData: AdaptyJsonData,
        _ completion: @escaping AdaptyJsonDataCompletion
    ) {
        Task {
            let result = await execute(withJson: jsonData)
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    @objc static func execute(
        method: String,
        withJsonData jsonData: AdaptyJsonData,
        _ completion: @escaping AdaptyJsonDataCompletion
    ) {
        Task {
            let result = await execute(method: method, withJson: jsonData)
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}
