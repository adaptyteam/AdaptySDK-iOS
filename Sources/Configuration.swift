//
//  Configuration.swift
//  AdaptySDK
//
//  Created by Dmitry Obukhov on 3/17/20.
//

import Foundation

extension Adapty {
    public struct Configuration: Sendable {
        static let `default` = Configuration(
            apiKey: "",
            customerUserId: nil,
            observerMode: false,
            idfaCollectionDisabled: false,
            ipAddressCollectionDisabled: false,
            dispatchQueue: .main,
            backendBaseUrl: Backend.publicEnvironmentBaseUrl,
            backendFallbackBaseUrl: Backend.publicEnvironmentFallbackBaseUrl,
            backendConfigsBaseUrl: Backend.publicEnvironmentConfigsBaseUrl,
            backendProxy: nil
        )

        let apiKey: String
        let customerUserId: String?
        let observerMode: Bool
        let idfaCollectionDisabled: Bool
        let ipAddressCollectionDisabled: Bool
        let dispatchQueue: DispatchQueue
        let backendBaseUrl: URL
        let backendFallbackBaseUrl: URL
        let backendConfigsBaseUrl: URL
        let backendProxy: (host: String, port: Int)?
    }
}

extension Adapty.Configuration {
    static var idfaCollectionDisabled: Bool = `default`.idfaCollectionDisabled
    static var ipAddressCollectionDisabled: Bool = `default`.ipAddressCollectionDisabled
    package internal(set) static var observerMode: Bool = `default`.observerMode
}

extension Backend {
    init(with configuration: Adapty.Configuration) {
        self.init(
            secretKey: configuration.apiKey,
            baseURL: configuration.backendBaseUrl,
            baseFallbackURL: configuration.backendFallbackBaseUrl,
            baseConfigsURL: configuration.backendConfigsBaseUrl,
            withProxy: configuration.backendProxy
        )
    }
}

extension Adapty.Configuration: Decodable {
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
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        apiKey = try container.decode(String.self, forKey: .apiKey)
        customerUserId = try container.decodeIfPresent(String.self, forKey: .customerUserId)
            ?? Self.default.customerUserId
        observerMode = try container.decodeIfPresent(Bool.self, forKey: .observerMode)
            ?? Self.default.observerMode
        idfaCollectionDisabled = try container.decodeIfPresent(Bool.self, forKey: .idfaCollectionDisabled)
            ?? Self.default.idfaCollectionDisabled
        ipAddressCollectionDisabled = try container.decodeIfPresent(Bool.self, forKey: .ipAddressCollectionDisabled)
            ?? Self.default.ipAddressCollectionDisabled
        dispatchQueue = Self.default.dispatchQueue
        backendBaseUrl = try container.decodeIfPresent(URL.self, forKey: .backendBaseUrl)
            ?? Self.default.backendBaseUrl
        backendFallbackBaseUrl = try container.decodeIfPresent(URL.self, forKey: .backendFallbackBaseUrl)
            ?? Self.default.backendFallbackBaseUrl
        backendConfigsBaseUrl = try container.decodeIfPresent(URL.self, forKey: .backendConfigsBaseUrl)
            ?? Self.default.backendConfigsBaseUrl
        if let host = try container.decodeIfPresent(String.self, forKey: .backendProxyHost),
           let port = try container.decodeIfPresent(Int.self, forKey: .backendProxyPort) {
            backendProxy = (host: host, port: port)
        } else {
            backendProxy = Self.default.backendProxy
        }
    }
}
