//
//  Backend.MainExecutor.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 02.10.2024
//

import Foundation

extension Backend {
    struct MainExecutor: BackendExecutor {
        let session: HTTPSession
    }

    func createMainExecutor() -> MainExecutor {
        MainExecutor(
            session: HTTPSession(configuration: self, responseValidator: validator)
        )
    }
}
