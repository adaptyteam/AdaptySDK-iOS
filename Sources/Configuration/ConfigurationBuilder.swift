//
//  Configuration.Builder.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.04.2024.
//

import Foundation

extension Adapty.Configuration {
    fileprivate init(with builder: Adapty.ConfigurationBuilder) {
        let apiKey = builder.apiKey
        assert(apiKey.count >= 41 && apiKey.starts(with: "public_live"), "It looks like you have passed the wrong apiKey value to the Adapty SDK.")

        self.init(
            apiKey: apiKey,
            customerUserId: builder.customerUserId,
            observerMode: builder.observerMode,
            idfaCollectionDisabled: builder.idfaCollectionDisabled,
            ipAddressCollectionDisabled: builder.ipAddressCollectionDisabled,
            backend: .init(
                baseUrl: builder.backendBaseUrl,
                fallbackUrl: builder.backendFallbackBaseUrl,
                configsUrl: builder.backendConfigsBaseUrl,
                proxy: builder.backendProxy
            ),
            crossPlatformSDK: builder.crossPlatformSDK
        )
    }

    public static func builder(withAPIKey apiKey: String) -> Adapty.ConfigurationBuilder {
        .init(withAPIKey: apiKey)
    }
}

extension Adapty {
    public final class ConfigurationBuilder {
        public private(set) var apiKey: String
        public private(set) var customerUserId: String?
        public private(set) var observerMode: Bool
        public private(set) var idfaCollectionDisabled: Bool
        public private(set) var ipAddressCollectionDisabled: Bool

        public private(set) var backendBaseUrl: URL
        public private(set) var backendFallbackBaseUrl: URL
        public private(set) var backendConfigsBaseUrl: URL
        public private(set) var backendProxy: (host: String, port: Int)?

        package private(set) var crossPlatformSDK: (name: String, version: String)?

        public convenience init(withAPIKey key: String) {
            self.init(apiKey: key)
        }

        init(
            apiKey: String,
            customerUserId: String? = Configuration.default.customerUserId,
            observerMode: Bool = Configuration.default.observerMode,
            idfaCollectionDisabled: Bool = Configuration.default.idfaCollectionDisabled,
            ipAddressCollectionDisabled: Bool = Configuration.default.ipAddressCollectionDisabled,
            backendBaseUrl: URL = Configuration.default.backend.baseUrl,
            backendFallbackBaseUrl: URL = Configuration.default.backend.fallbackUrl,
            backendConfigsBaseUrl: URL = Configuration.default.backend.configsUrl,
            backendProxy: (host: String, port: Int)? = Configuration.default.backend.proxy,
            crossPlatformSDK: (name: String, version: String)? = Configuration.default.crossPlatformSDK
        ) {
            self.apiKey = apiKey
            self.customerUserId = customerUserId
            self.observerMode = observerMode
            self.idfaCollectionDisabled = idfaCollectionDisabled
            self.ipAddressCollectionDisabled = ipAddressCollectionDisabled
            self.backendBaseUrl = backendBaseUrl
            self.backendFallbackBaseUrl = backendFallbackBaseUrl
            self.backendConfigsBaseUrl = backendConfigsBaseUrl
            self.backendProxy = backendProxy
            self.crossPlatformSDK = crossPlatformSDK
        }

        /// Call this method to get the ``Adapty.Configuration`` object.
        public func build() -> Adapty.Configuration {
            .init(with: self)
        }
    }
}

extension Adapty.ConfigurationBuilder {
    /// - Parameter apiKey: You can find it in your app settings in [Adapty Dashboard](https://app.adapty.io/) *App settings* > *General*.
    public func with(apiKey key: String) -> Self {
        apiKey = key
        return self
    }

    /// - Parameter customerUserId: User identifier in your system
    public func with(customerUserId id: String?) -> Self {
        customerUserId = id
        return self
    }

    /// - Parameter observerMode: A boolean value controlling [Observer mode](https://docs.adapty.io/docs/observer-vs-full-mode/). Turn it on if you handle purchases and subscription status yourself and use Adapty for sending subscription events and analytics
    public func with(observerMode mode: Bool) -> Self {
        observerMode = mode
        return self
    }

    /// - Parameter idfaCollectionDisabled: A boolean value controlling idfa collection logic
    public func with(idfaCollectionDisabled value: Bool) -> Self {
        idfaCollectionDisabled = value
        return self
    }

    /// - Parameter ipAddressCollectionDisabled: A boolean value controlling ip-address collection logic
    public func with(ipAddressCollectionDisabled value: Bool) -> Self {
        ipAddressCollectionDisabled = value
        return self
    }

    public func with(backendBaseUrl url: URL) -> Self {
        backendBaseUrl = url
        return self
    }

    public func with(backendFallbackBaseUrl url: URL) -> Self {
        backendFallbackBaseUrl = url
        return self
    }

    public func with(backendConfigsBaseUrl url: URL) -> Self {
        backendConfigsBaseUrl = url
        return self
    }

    public func with(proxy host: String, port: Int) -> Self {
        backendProxy = (host: host, port: port)
        return self
    }

    package func with(crosplatformSDKName name: String, version: String) -> Self {
        crossPlatformSDK = (name: name, version: version)
        return self
    }
}
