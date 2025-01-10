//
//  Backend.ConfigsExecutor.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 02.10.2024
//

import Foundation

extension Backend {
    struct ConfigsExecutor: BackendExecutor {
        let session: HTTPSession
    }

    func createConfigsExecutor() -> ConfigsExecutor {
        ConfigsExecutor(
            session: HTTPSession(configuration: configs)
        )
    }
}
