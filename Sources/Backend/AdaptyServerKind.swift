//
//  AdaptyServerKind.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 12.11.2025.
//

import Foundation

package enum AdaptyServerKind: Sendable, CaseIterable {
    case main
    case fallback
    case configs
    case ua

    fileprivate static let basePath = "/api/v1"

    func defaultBaseUrl(by cluster: AdaptyServerCluster) -> URL {
        switch (self, cluster) {
        case (.main, .eu):
            URL(string: "https://api-eu.adapty.io\(Self.basePath)")!
        case (.main, .cn):
            URL(string: "https://api-cn.adapty.io\(Self.basePath)")!
        case (.main, _):
            URL(string: "https://api.adapty.io\(Self.basePath)")!
        case (.fallback, .cn):
            URL(string: "https://fallback-cn.adapty.io\(Self.basePath)")!
        case (.fallback, _):
            URL(string: "https://fallback.adapty.io\(Self.basePath)")!
        case (.configs, .cn):
            URL(string: "https://configs-cdn-cn.adapty.io\(Self.basePath)")!
        case (.configs, _):
            URL(string: "https://configs-cdn.adapty.io\(Self.basePath)")!
        case (.ua, .cn):
            URL(string: "https://api-ua-cn.adapty.io\(Self.basePath)")!
        case (.ua, _):
            URL(string: "https://api-ua.adapty.io\(Self.basePath)")!
        }
    }

    func baseUrl(dev: [AdaptyServerKind: URL]?, by cluster: AdaptyServerCluster) -> URL {
        dev?[self] ?? self.defaultBaseUrl(by: cluster)
    }
}

extension URL {
    var appendingDefaultPathIfNeed: Self {
        guard path.isEmpty || path == "/" else { return self }
        return appendingPathComponent(AdaptyServerKind.basePath)
    }
}
