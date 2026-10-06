//
//  Backend.ConfigsExecutor.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 02.10.2024
//

import Foundation

extension Backend {
    typealias ConfigsExecutor = FallbackExecutor

    func createConfigsExecutor() -> ConfigsExecutor {
        ConfigsExecutor(
            manager: networkManager,
            session: HTTPSession(configuration: configsHTTPConfiguration),
            kind: .configs
        )
    }
}
