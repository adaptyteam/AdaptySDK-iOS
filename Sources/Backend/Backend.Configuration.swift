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
        let devBaseUrls: [AdaptyServerKind: URL]?
        let proxy: (host: String, port: Int)?
        let protocolClasses: [AnyClass]?

        init(
            cluster: AdaptyServerCluster = .default,
            devBaseUrls: [AdaptyServerKind: URL]? = nil,
            proxy: (host: String, port: Int)? = nil,
            protocolClasses: [AnyClass]? = nil
        ) {
            self.cluster = cluster
            self.devBaseUrls = devBaseUrls
            self.proxy = proxy
            self.protocolClasses = protocolClasses
        }
    }
}
