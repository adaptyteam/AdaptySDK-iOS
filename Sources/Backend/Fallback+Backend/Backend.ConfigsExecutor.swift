//
//  Backend.ConfigsExecutor.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 02.10.2024
//

import Foundation

extension Backend {
    struct ConfigsExecutor: BackendExecutor {
        let manager: StateManager
        let session: HTTPSession
        let kind = AdaptyServerKind.configs
    }

    func createConfigsExecutor() -> ConfigsExecutor {
        ConfigsExecutor(
            manager: networkManager,
            session: HTTPSession(configuration: defaultHTTPConfiguration)
        )
    }
}
