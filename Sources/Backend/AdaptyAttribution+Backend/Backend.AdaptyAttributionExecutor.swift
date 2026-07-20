//
//  Backend.AdaptyAttributionExecutor.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 09.06.2025.
//

import Foundation

extension Backend {
    struct AdaptyAttributionExecutor: BackendExecutor {
        let manager: StateManager
        let session: HTTPSession
        let kind = AdaptyServerKind.adaptyAttribution
    }

    func createAdaptyAttributionExecutor() -> AdaptyAttributionExecutor {
        AdaptyAttributionExecutor(
            manager: networkManager,
            session: HTTPSession(configuration: adaptyAttributionHTTPConfiguration, responseValidator: validator)
        )
    }
}

extension Backend.AdaptyAttributionExecutor {
    func canRetryRequest(_ error: HTTPError) -> Bool {
        switch error {
        case .perform:
            false
        case let .network(_, _, _, error: error):
            (error as NSError).isNetworkConnectionError
        case let .decoding(_, _, statusCode, _, _, _),
             let .backend(_, _, statusCode, _, _, _):
            switch statusCode {
            case 429, 499, 500 ... 599:
                true
            case 400 ... 499:
                false
            default:
                true
            }
        }
    }
}
