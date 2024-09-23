//
//  Configuration+Decodable.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.04.2024.
//

import Foundation

extension Adapty.ConfigurationBuilder: Decodable {
    enum CodingKeys: String, CodingKey {
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

        case crossPlatformSDKName = "cross_platform_sdk_name"
        case crossPlatformSDKVersion = "cross_platform_sdk_version"
    }

    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let defaultValue = Adapty.Configuration.default

        let proxy: (host: String, port: Int)? =
            if let host = try container.decodeIfPresent(String.self, forKey: .backendProxyHost),
            let port = try container.decodeIfPresent(Int.self, forKey: .backendProxyPort) {
                (host: host, port: port)
            } else {
                defaultValue.backend.proxy
            }

        let crossPlatformSDK: (name: String, version: String)? =
            if let name = try container.decodeIfPresent(String.self, forKey: .crossPlatformSDKName),
            let version = try container.decodeIfPresent(String.self, forKey: .crossPlatformSDKVersion) {
                (name: name, version: version)
            } else {
                defaultValue.crossPlatformSDK
            }

        try self.init(
            apiKey: container.decode(String.self, forKey: .apiKey),
            customerUserId: container.decodeIfPresent(String.self, forKey: .customerUserId),
            observerMode: container.decodeIfPresent(Bool.self, forKey: .observerMode)
                ?? defaultValue.observerMode,
            idfaCollectionDisabled: container.decodeIfPresent(Bool.self, forKey: .idfaCollectionDisabled)
                ?? defaultValue.idfaCollectionDisabled,
            ipAddressCollectionDisabled: container.decodeIfPresent(Bool.self, forKey: .ipAddressCollectionDisabled)
                ?? defaultValue.ipAddressCollectionDisabled,
            backendBaseUrl: container.decodeIfPresent(URL.self, forKey: .backendBaseUrl) ?? defaultValue.backend.baseUrl,
            backendFallbackBaseUrl: container.decodeIfPresent(URL.self, forKey: .backendFallbackBaseUrl)
                ?? defaultValue.backend.fallbackUrl,
            backendConfigsBaseUrl: container.decodeIfPresent(URL.self, forKey: .backendConfigsBaseUrl)
                ?? defaultValue.backend.configsUrl,
            backendProxy: proxy,
            crossPlatformSDK: crossPlatformSDK
        )
    }
}
