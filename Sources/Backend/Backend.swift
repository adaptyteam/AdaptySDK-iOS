//
//  Backend.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation

package struct Backend {
    let networkManager: StateManager

    let defaultHTTPConfiguration: HTTPCodableConfiguration
    let adaptyAttributionHTTPConfiguration: HTTPCodableConfiguration
    let fallbackHTTPConfiguration: HTTPCodableConfiguration
    var configsHTTPConfiguration: HTTPCodableConfiguration {
        fallbackHTTPConfiguration
    }

    init(
        with configuration: AdaptyConfiguration,
        environment: Environment
    ) async {
        defaultHTTPConfiguration = MainHTTPConfiguration(with: configuration, environment: environment)
        fallbackHTTPConfiguration = FallbackHTTPConfiguration(with: configuration)
        adaptyAttributionHTTPConfiguration = AdaptyAttributionHTTPConfiguration(with: configuration, environment: environment)

        networkManager = await Backend.StateManager(with: configuration)
    }

    enum Request {}
    enum Response {}
}
