//
//  Configuration.Builder.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.04.2024.
//

import Foundation

extension Adapty.Configuration {
    init(with builder: Builder) {
        self.init(
            apiKey: builder.apiKey,
            customerUserId: builder.customerUserId,
            observerMode: builder.observerMode,
            idfaCollectionDisabled: builder.idfaCollectionDisabled,
            ipAddressCollectionDisabled: builder.ipAddressCollectionDisabled,
            dispatchQueue: builder.dispatchQueue,
            backendBaseUrl: builder.backendBaseUrl,
            backendFallbackBaseUrl: builder.backendFallbackBaseUrl,
            backendConfigsBaseUrl: builder.backendConfigsBaseUrl,
            backendProxy: builder.backendProxy
        )
    }

    public static func builder(withAPIKey apiKey: String) -> Builder {
        .init(withAPIKey: apiKey)
    }

    public final class Builder {
        public private(set) var apiKey: String
        public private(set) var customerUserId: String?
        public private(set) var observerMode: Bool
        public private(set) var idfaCollectionDisabled: Bool
        public private(set) var ipAddressCollectionDisabled: Bool
        public private(set) var dispatchQueue: DispatchQueue
        public private(set) var backendBaseUrl: URL
        public private(set) var backendFallbackBaseUrl: URL
        public private(set) var backendConfigsBaseUrl: URL
        public private(set) var backendProxy: (host: String, port: Int)?

        public convenience init(withAPIKey key: String) {
            assert(key.count >= 41 && key.starts(with: "public_live"), "It looks like you have passed the wrong apiKey value to the Adapty SDK.")
            self.init(Adapty.Configuration.default)
            apiKey = key
        }

        init(_ configuration: Adapty.Configuration) {
            self.apiKey = configuration.apiKey
            self.customerUserId = configuration.customerUserId
            self.observerMode = configuration.observerMode
            self.idfaCollectionDisabled = configuration.idfaCollectionDisabled
            self.ipAddressCollectionDisabled = configuration.ipAddressCollectionDisabled
            self.dispatchQueue = configuration.dispatchQueue
            self.backendBaseUrl = configuration.backendBaseUrl
            self.backendFallbackBaseUrl = configuration.backendFallbackBaseUrl
            self.backendConfigsBaseUrl = configuration.backendConfigsBaseUrl
            self.backendProxy = configuration.backendProxy
        }

        /// Call this method to get the ``Adapty.Configuration`` object.
        public func build() -> Adapty.Configuration { .init(with: self) }

        /// - Parameter apiKey: You can find it in your app settings in [Adapty Dashboard](https://app.adapty.io/) *App settings* > *General*.
        public func with(apiKey key: String) -> Builder {
            assert(key.count >= 41 && key.starts(with: "public_live"), "It looks like you have passed the wrong apiKey value to the Adapty SDK.")
            apiKey = key
            return self
        }

        /// - Parameter customerUserId: User identifier in your system
        public func with(customerUserId id: String?) -> Builder {
            customerUserId = id
            return self
        }

        /// - Parameter observerMode: A boolean value controlling [Observer mode](https://adapty.io/docs/3.0/observer-vs-full-mode). Turn it on if you handle purchases and subscription status yourself and use Adapty for sending subscription events and analytics
        public func with(observerMode mode: Bool) -> Builder {
            observerMode = mode
            return self
        }

        /// - Parameter idfaCollectionDisabled: A boolean value controlling idfa collection logic
        public func with(idfaCollectionDisabled value: Bool) -> Builder {
            idfaCollectionDisabled = value
            return self
        }

        /// - Parameter ipAddressCollectionDisabled: A boolean value controlling ip-address collection logic
        public func with(ipAddressCollectionDisabled value: Bool) -> Builder {
            ipAddressCollectionDisabled = value
            return self
        }

        /// - Parameter dispatchQueue: Specify the Dispatch Queue where callbacks will be executed
        public func with(dispatchQueue queue: DispatchQueue) -> Builder {
            dispatchQueue = queue
            return self
        }

        public func with(backendBaseUrl url: URL) -> Builder {
            backendBaseUrl = url
            return self
        }

        public func with(backendFallbackBaseUrl url: URL) -> Builder {
            backendFallbackBaseUrl = url
            return self
        }

        public func with(backendConfigsBaseUrl url: URL) -> Builder {
            backendConfigsBaseUrl = url
            return self
        }
        
        public func with(proxy host: String, port: Int) -> Builder {
            backendProxy = (host: host, port: port)
            return self
        }
    }
}
