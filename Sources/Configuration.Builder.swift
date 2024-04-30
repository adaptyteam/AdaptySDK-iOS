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
            self.backendProxy = configuration.backendProxy
        }

        public func build() -> Adapty.Configuration { .init(with: self) }

        public func with(apiKey key: String) -> Builder {
            assert(key.count >= 41 && key.starts(with: "public_live"), "It looks like you have passed the wrong apiKey value to the Adapty SDK.")
            apiKey = key
            return self
        }

        public func with(customerUserId id: String?) -> Builder {
            customerUserId = id
            return self
        }

        public func with(observerMode mode: Bool) -> Builder {
            observerMode = mode
            return self
        }

        public func with(idfaCollectionDisabled value: Bool) -> Builder {
            idfaCollectionDisabled = value
            return self
        }

        public func with(ipAddressCollectionDisabled value: Bool) -> Builder {
            ipAddressCollectionDisabled = value
            return self
        }

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

        public func with(proxy host: String, port: Int) -> Builder {
            backendProxy = (host: host, port: port)
            return self
        }
    }
}
