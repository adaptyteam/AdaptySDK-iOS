//
//  Backend.UAExecuter.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 09.06.2025.
//

import Foundation

extension Backend {
    struct UAExecutor: BackendExecutor {
        let session: HTTPSession
    }

    func createUAExecutor() -> UAExecutor {
        UAExecutor(
            session: HTTPSession(configuration: ua, responseValidator: validator)
        )
    }
}
