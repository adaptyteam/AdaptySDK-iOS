//
//  AdaptyJsonDataCompletion.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 08.11.2024.
//

import Foundation

public typealias AdaptyJsonDataCompletion = @Sendable (AdaptyJsonData) -> Void

func withCompletion(
    _ completion: @escaping AdaptyJsonDataCompletion,
    from operation: @escaping @Sendable () async -> AdaptyJsonData
) {
    Task {
        let result = await operation()

        DispatchQueue.main.async {
            completion(result)
        }
    }
}
