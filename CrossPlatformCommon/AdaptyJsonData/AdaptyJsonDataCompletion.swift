//
//  AdaptyJsonDataCompletion.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import Foundation

public typealias AdaptyJsonDataCompletion = @Sendable (AdaptyJsonData) -> Void

extension AdaptyPlugin {
    static func execute<Request: AdaptyPluginRequest>(with completion: @escaping AdaptyJsonDataCompletion, instance: @escaping @Sendable () throws -> Request) {
        Task {
            let result = await execute(instance: instance)

            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}
