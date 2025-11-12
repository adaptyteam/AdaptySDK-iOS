//
//  Backend.DefaultExecutor.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 02.10.2024
//

import Foundation

extension Backend {
    struct MainExecutor: BackendExecutor {
        let manager: Backend.NetworkManager
        let session: HTTPSession
        let kind = AdaptyServerKind.main
    }

    func createDefaultExecutor() -> MainExecutor {
        MainExecutor(
            manager: networkManager,
            session: HTTPSession(configuration: defaultHTTPConfiguration, responseValidator: validator)
        )
    }
}
