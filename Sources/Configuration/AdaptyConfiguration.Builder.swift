//
//  AdaptyConfiguration.Builder.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.04.2024.
//

import Foundation

extension AdaptyConfiguration {
    fileprivate init(with builder: AdaptyConfiguration.Builder) {
        let apiKey = builder.apiKey
        assert(apiKey.count >= 41 && apiKey.starts(with: "public_live"), "It looks like you have passed the wrong apiKey value to the Adapty SDK.")

        let defaultValue = AdaptyConfiguration.default

        let defaultBackend =
            switch builder.serverCluster ?? .default {
            case .eu:
                Backend.URLs.euPublicEnvironment
            case .cn:
                Backend.URLs.cnPublicEnvironment
            default:
                Backend.URLs.defaultPublicEnvironment
            }

        self.init(
            apiKey: apiKey.trimmed,
            customerUserId: builder.customerUserId.trimmed.nonEmptyOrNil,
            appAccountToken: builder.appAccountToken,
            observerMode: builder.observerMode ?? defaultValue.observerMode,
            idfaCollectionDisabled: builder.idfaCollectionDisabled ?? defaultValue.idfaCollectionDisabled,
            ipAddressCollectionDisabled: builder.ipAddressCollectionDisabled ?? defaultValue.ipAddressCollectionDisabled,
            callbackDispatchQueue: builder.callbackDispatchQueue,
            backend: .init(
                baseUrl: builder.backendBaseUrl ?? defaultBackend.baseUrl,
                fallbackUrl: builder.backendFallbackBaseUrl ?? defaultBackend.fallbackUrl,
                configsUrl: builder.backendConfigsBaseUrl ?? defaultBackend.configsUrl,
                uaUrl: builder.backendUABaseUrl ?? defaultBackend.uaUrl,
                proxy: builder.backendProxy ?? defaultBackend.proxy
            ),
            logLevel: builder.logLevel,
            crossPlatformSDK: builder.crossPlatformSDK.map {
                (name: $0.name.trimmed, version: $0.version.trimmed)
            }
        )
    }

    public static func builder(withAPIKey apiKey: String) -> AdaptyConfiguration.Builder {
        .init(
            apiKey: apiKey.trimmed,
            customerUserId: nil,
            appAccountToken: nil,
            observerMode: nil,
            idfaCollectionDisabled: nil,
            ipAddressCollectionDisabled: nil,
            callbackDispatchQueue: nil,
            serverCluster: nil,
            backendBaseUrl: nil,
            backendFallbackBaseUrl: nil,
            backendConfigsBaseUrl: nil,
            backendUABaseUrl: nil,
            backendProxy: nil,
            logLevel: nil,
            crossPlatformSDK: nil
        )
    }
}

public extension AdaptyConfiguration {
    final class Builder {
        public private(set) var apiKey: String
        public private(set) var customerUserId: String?
        public private(set) var appAccountToken: UUID?
        public private(set) var observerMode: Bool?
        public private(set) var idfaCollectionDisabled: Bool?
        public private(set) var ipAddressCollectionDisabled: Bool?
        public private(set) var callbackDispatchQueue: DispatchQueue?

        public private(set) var serverCluster: ServerCluster?
        public private(set) var backendBaseUrl: URL?
        public private(set) var backendFallbackBaseUrl: URL?
        public private(set) var backendConfigsBaseUrl: URL?
        public private(set) var backendUABaseUrl: URL?
        public private(set) var backendProxy: (host: String, port: Int)?

        public private(set) var logLevel: AdaptyLog.Level?

        package private(set) var crossPlatformSDK: (name: String, version: String)?

        init(
            apiKey: String,
            customerUserId: String?,
            appAccountToken: UUID?,
            observerMode: Bool?,
            idfaCollectionDisabled: Bool?,
            ipAddressCollectionDisabled: Bool?,
            callbackDispatchQueue: DispatchQueue?,
            serverCluster: ServerCluster?,
            backendBaseUrl: URL?,
            backendFallbackBaseUrl: URL?,
            backendConfigsBaseUrl: URL?,
            backendUABaseUrl: URL?,
            backendProxy: (host: String, port: Int)?,
            logLevel: AdaptyLog.Level?,
            crossPlatformSDK: (name: String, version: String)?
        ) {
            self.apiKey = apiKey
            self.customerUserId = customerUserId
            self.appAccountToken = appAccountToken
            self.observerMode = observerMode
            self.idfaCollectionDisabled = idfaCollectionDisabled
            self.ipAddressCollectionDisabled = ipAddressCollectionDisabled
            self.callbackDispatchQueue = callbackDispatchQueue
            self.serverCluster = serverCluster ?? .default
            self.backendBaseUrl = backendBaseUrl
            self.backendFallbackBaseUrl = backendFallbackBaseUrl
            self.backendConfigsBaseUrl = backendConfigsBaseUrl
            self.backendUABaseUrl = backendUABaseUrl
            self.backendProxy = backendProxy
            self.logLevel = logLevel
            self.crossPlatformSDK = crossPlatformSDK
        }

        /// Call this method to get the ``AdaptyConfiguration`` object.
        public func build() -> AdaptyConfiguration {
            .init(with: self)
        }
    }
}

public extension AdaptyConfiguration.Builder {
    /// - Parameter apiKey: You can find it in your app settings in [Adapty Dashboard](https://app.adapty.io/) *App settings* > *General*.
    @discardableResult
    func with(apiKey key: String) -> Self {
        apiKey = key
        return self
    }

    /// - Parameter customerUserId: User identifier in your system
    @discardableResult
    func with(customerUserId id: String?, withAppAccountToken token: UUID? = nil) -> Self {
        customerUserId = id
        appAccountToken = id != nil ? token : nil
        return self
    }

    /// - Parameter observerMode: A boolean value controlling [Observer mode](https://docs.adapty.io/docs/observer-vs-full-mode/). Turn it on if you handle purchases and subscription status yourself and use Adapty for sending subscription events and analytics
    @discardableResult
    func with(observerMode mode: Bool) -> Self {
        observerMode = mode
        return self
    }

    /// - Parameter idfaCollectionDisabled: A boolean value controlling idfa collection logic
    @discardableResult
    func with(idfaCollectionDisabled value: Bool) -> Self {
        idfaCollectionDisabled = value
        return self
    }

    /// - Parameter ipAddressCollectionDisabled: A boolean value controlling ip-address collection logic
    @discardableResult
    func with(ipAddressCollectionDisabled value: Bool) -> Self {
        ipAddressCollectionDisabled = value
        return self
    }

    /// - Parameter dispatchQueue: Specify the Dispatch Queue where callbacks will be executed
    @discardableResult
    func with(callbackDispatchQueue queue: DispatchQueue) -> Self {
        callbackDispatchQueue = queue
        return self
    }

    @discardableResult
    func with(serverCluster value: AdaptyConfiguration.ServerCluster) -> Self {
        serverCluster = value
        return self
    }

    @discardableResult
    func with(backendBaseUrl url: URL) -> Self {
        backendBaseUrl = url
        return self
    }

    @discardableResult
    func with(backendFallbackBaseUrl url: URL) -> Self {
        backendFallbackBaseUrl = url
        return self
    }

    @discardableResult
    func with(backendConfigsBaseUrl url: URL) -> Self {
        backendConfigsBaseUrl = url
        return self
    }

    @discardableResult
    func with(backendUABaseUrl url: URL) -> Self {
        backendUABaseUrl = url
        return self
    }

    @discardableResult
    func with(proxy host: String, port: Int) -> Self {
        backendProxy = (host: host.trimmed, port: port)
        return self
    }

    @discardableResult
    func with(logLevel level: AdaptyLog.Level) -> Self {
        logLevel = level
        return self
    }

    @discardableResult
    package func with(crossplatformSDKName name: String, version: String) -> Self {
        crossPlatformSDK = (name: name, version: version)
        return self
    }
}
