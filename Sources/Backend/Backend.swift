//
//  Backend.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation

package struct Backend {
    let networkManager: NetworkManager

    let defaultHTTPConfiguration: HTTPCodableConfiguration
    let uaHTTPConfiguration: HTTPCodableConfiguration
    let fallbackHTTPConfiguration: HTTPCodableConfiguration
    var configsHTTPConfiguration: HTTPCodableConfiguration { fallbackHTTPConfiguration }

    init(
        with configuration: AdaptyConfiguration,
        networkManager: NetworkManager,
        environment: Environment
    ) {
        self.networkManager = networkManager

        defaultHTTPConfiguration = DefaultHTTPConfiguration(with: configuration, environment: environment)
        fallbackHTTPConfiguration = FallbackHTTPConfiguration(with: configuration)
        uaHTTPConfiguration = UAHTTPConfiguration(with: configuration, environment: environment)
    }

    enum Request {}
    enum Response {}
}
