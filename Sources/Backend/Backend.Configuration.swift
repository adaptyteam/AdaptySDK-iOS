//
//  Backend.Configuration.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.10.2023
//

import Foundation

extension Backend {
    struct Configuration {
        let cluster: AdaptyServerCluster
        let mainBaseUrl: URL?
        let fallbackBaseUrl: URL?
        let configsBaseUrl: URL?
        let uaBaseUrl: URL?
        let proxy: (host: String, port: Int)?
        let protocolClasses: [AnyClass]?

        init(
            cluster: AdaptyServerCluster = .default,
            mainBaseUrl: URL? = nil,
            fallbackBaseUrl: URL? = nil,
            configsBaseUrl: URL? = nil,
            uaBaseUrl: URL? = nil,
            proxy: (host: String, port: Int)? = nil,
            protocolClasses: [AnyClass]? = nil
        ) {
            self.cluster = cluster
            self.mainBaseUrl = mainBaseUrl
            self.fallbackBaseUrl = fallbackBaseUrl
            self.configsBaseUrl = configsBaseUrl
            self.uaBaseUrl = uaBaseUrl
            self.proxy = proxy
            self.protocolClasses = protocolClasses
        }
    }
}
