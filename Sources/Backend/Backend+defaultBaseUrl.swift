//
//  AdaptyServerKind+.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 12.11.2025.
//

import Foundation

extension Backend {
    fileprivate static let basePath = "/api/v1"

    static func defaultBaseUrl(kind: AdaptyServerKind, by cluster: AdaptyServerCluster) -> URL {
        switch kind {
        case .main: switch cluster {
            case .eu: URL(string: "https://api-eu.adapty.io\(basePath)")!
            case .cn: URL(string: "https://api-cn.adapty.io\(basePath)")!
            default: URL(string: "https://api.adapty.io\(basePath)")!
            }
        case .fallback: switch cluster {
            case .cn: URL(string: "https://fallback-cn.adapty.io\(basePath)")!
            default: URL(string: "https://fallback.adapty.io\(basePath)")!
            }
        case .configs: switch cluster {
            case .cn: URL(string: "https://configs-cdn-cn.adapty.io\(basePath)")!
            default: URL(string: "https://configs-cdn.adapty.io\(basePath)")!
            }
        case .ua: switch cluster {
            case .cn: URL(string: "https://api-ua-cn.adapty.io\(basePath)")!
            default: URL(string: "https://api-ua.adapty.io\(basePath)")!
            }
        }
    }
}

extension URL {
    var appendingDefaultPathIfNeed: Self {
        guard path.isEmpty || path == "/" else { return self }
        return appendingPathComponent(Backend.basePath)
    }
}

extension [AdaptyServerKind: URL] {
    subscript(_ kind: AdaptyServerKind, with cluster: AdaptyServerCluster) -> URL {
        self[kind] ?? Backend.defaultBaseUrl(kind: kind, by: cluster)
    }
}

extension [AdaptyServerKind: URL]? {
    subscript(_ kind: AdaptyServerKind, with cluster: AdaptyServerCluster) -> URL {
        self?[kind] ?? Backend.defaultBaseUrl(kind: kind, by: cluster)
    }
}
