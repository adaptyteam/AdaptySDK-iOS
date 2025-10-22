//
//  Backend.Configuration.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.10.2023
//

import Foundation

extension Backend {
    enum Defaults: Sendable {
        static let mainBaseUrl = URL(string: "https://api.adapty.io/api/v1")!
        static let fallbackBaseUrl = URL(string: "https://fallback.adapty.io/api/v1")!
        static let configsBaseUrl = URL(string: "https://configs-cdn.adapty.io/api/v1")!
        static let uaBaseUrl = URL(string: "https://api-ua.adapty.io/api/v1")!

        static func mainBaseUrl(by cluster: AdaptyServerCluster) -> URL {
            switch cluster {
            case .eu:
                URL(string: "https://api-eu.adapty.io/api/v1")!
            case .cn:
                URL(string: "https://api-cn.adapty.io/api/v1")!
            default:
                mainBaseUrl
            }
        }
    }

    struct Configuration {
        let mainBaseUrl: URL
        let fallbackBaseUrl: URL
        let configsBaseUrl: URL
        let uaBaseUrl: URL
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
            self.mainBaseUrl = mainBaseUrl ?? Defaults.mainBaseUrl(by: cluster)
            self.fallbackBaseUrl = fallbackBaseUrl ?? Defaults.fallbackBaseUrl
            self.configsBaseUrl = configsBaseUrl ?? Defaults.configsBaseUrl
            self.uaBaseUrl = uaBaseUrl ?? Defaults.uaBaseUrl
            self.proxy = proxy
            self.protocolClasses = protocolClasses
        }
    }
}
