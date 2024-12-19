//
//  AdaptyConfiguration.Builder+Decodable.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.04.2024.
//

import Foundation

extension AdaptyConfiguration.Builder: Decodable {
    private enum CodingKeys: String, CodingKey {
        case apiKey = "api_key"
        case customerUserId = "customer_user_id"
        case observerMode = "observer_mode"
        case idfaCollectionDisabled = "idfa_collection_disabled"
        case ipAddressCollectionDisabled = "ip_address_collection_disabled"

        case backendBaseUrl = "backend_base_url"
        case backendFallbackBaseUrl = "backend_fallback_base_url"
        case backendConfigsBaseUrl = "backend_configs_base_url"
        case backendProxyHost = "backend_proxy_host"
        case backendProxyPort = "backend_proxy_port"

        case logLevel = "log_level"

        case crossPlatformSDKName = "cross_platform_sdk_name"
        case crossPlatformSDKVersion = "cross_platform_sdk_version"
        
        case serverCluster = "server_cluster"
    }

    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let proxy: (host: String, port: Int)? =
            if let host = try container.decodeIfPresent(String.self, forKey: .backendProxyHost),
            let port = try container.decodeIfPresent(Int.self, forKey: .backendProxyPort) {
                (host: host, port: port)
            } else {
                nil
            }

        let crossPlatformSDK: (name: String, version: String)? =
            if let name = try container.decodeIfPresent(String.self, forKey: .crossPlatformSDKName),
            let version = try container.decodeIfPresent(String.self, forKey: .crossPlatformSDKVersion) {
                (name: name, version: version)
            } else {
                nil
            }

        try self.init(
            apiKey: container.decode(String.self, forKey: .apiKey),
            customerUserId: container.decodeIfPresent(String.self, forKey: .customerUserId),
            observerMode: container.decodeIfPresent(Bool.self, forKey: .observerMode),
            idfaCollectionDisabled: container.decodeIfPresent(Bool.self, forKey: .idfaCollectionDisabled),
            ipAddressCollectionDisabled: container.decodeIfPresent(Bool.self, forKey: .ipAddressCollectionDisabled),
            callbackDispatchQueue: nil,
            serverCluster: container.decodeIfPresent(AdaptyConfiguration.ServerCluster.self, forKey: .serverCluster),
            backendBaseUrl: container.decodeIfPresent(URL.self, forKey: .backendBaseUrl),
            backendFallbackBaseUrl: container.decodeIfPresent(URL.self, forKey: .backendFallbackBaseUrl),
            backendConfigsBaseUrl: container.decodeIfPresent(URL.self, forKey: .backendConfigsBaseUrl),
            backendProxy: proxy,
            logLevel: container.decodeIfPresent(AdaptyLog.Level.self, forKey: .logLevel),
            crossPlatformSDK: crossPlatformSDK
        )
    }
}

extension AdaptyConfiguration.ServerCluster: Decodable {
    public init(from decoder: Decoder) throws {
        self = switch try decoder.singleValueContainer().decode(String.self) {
            case "eu":  .eu
            default: .default
        }
    }
}

