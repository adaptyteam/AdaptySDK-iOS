//
//  Adapty+Activate.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 22.09.2024
//

import Foundation

private let log = Log.default

extension Adapty {
    /// Use this method to initialize the Adapty SDK.
    ///
    /// Call this method in the `application(_:didFinishLaunchingWithOptions:)`.
    ///
    /// - Parameter apiKey: You can find it in your app settings in [Adapty Dashboard](https://app.adapty.io/) *App settings* > *General*.
    /// - Parameter observerMode: A boolean value controlling [Observer mode](https://docs.adapty.io/v2.0.0/docs/observer-vs-full-mode). Turn it on if you handle purchases and subscription status yourself and use Adapty for sending subscription events and analytics
    /// - Parameter customerUserId: User identifier in your system
    public nonisolated static func activate(
        _ apiKey: String,
        observerMode: Bool = false,
        customerUserId: String? = nil
    ) async throws {
        try await activate(
            with: Configuration
                .builder(withAPIKey: apiKey)
                .with(customerUserId: customerUserId)
                .with(observerMode: observerMode)
                .build()
        )
    }

    /// Use this method to initialize the Adapty SDK.
    ///
    /// Call this method in the `application(_:didFinishLaunchingWithOptions:)`.
    ///
    /// - Parameter builder: `Adapty.ConfigurationBuilder` which allows to configure Adapty SDK
    public nonisolated static func activate(
        with builder: Adapty.ConfigurationBuilder
    ) async throws {
        try await activate(with: builder.build())
    }

    public private(set) static var isActivated: Bool = false

    /// Use this method to initialize the Adapty SDK.
    ///
    /// Call this method in the `application(_:didFinishLaunchingWithOptions:)`.
    ///
    /// - Parameter configuration: `Adapty.Configuration` which allows to configure Adapty SDK
    public nonisolated static func activate(
        with configuration: Adapty.Configuration
    ) async throws {
        try await withOptioanalSDK(
            methodName: .activate,
            logParams: [
                "observer_mode": configuration.observerMode,
                "has_customer_user_id": configuration.customerUserId != nil,
                "idfa_collection_disabled": configuration.idfaCollectionDisabled,
                "ip_address_collection_disabled": configuration.ipAddressCollectionDisabled,
            ]
        ) { @AdaptyActor _ in

            if Adapty.isActivated {
                let error = AdaptyError.activateOnceError()
                log.warn("Adapty activate error \(error)")
                throw error
            }

            Adapty.isActivated = true

            if let logLevel = configuration.logLevel { Adapty.logLevel = logLevel }

            UserDefaults.standard.clearAllDataIfDifferent(apiKey: configuration.apiKey)

            Adapty.callbackDispatchQueue = configuration.callbackDispatchQueue
            Configuration.idfaCollectionDisabled = configuration.idfaCollectionDisabled
            Configuration.ipAddressCollectionDisabled = configuration.ipAddressCollectionDisabled
            Configuration.observerModeEnabled = configuration.observerMode
            
            let environment = await Environment.instance
            let backend = Backend(with: configuration, envorinment: environment)

            Task {
                await Adapty.eventsManager.set(backend: backend)
            }

            set(shared: Adapty(
                apiKeyPrefix: String(configuration.apiKey.prefix(while: { $0 != "." })),
                profileStorage: UserDefaults.standard,
                backend: backend,
                customerUserId: configuration.customerUserId,
                isObserveMode: configuration.observerMode
            ))

//            LifecycleManager.shared.initialize()

            log.info("Adapty activated withObserverMode:\(configuration.observerMode), withCustomerUserId: \(configuration.customerUserId != nil)")
        }
    }
}

package extension Adapty.Configuration {
    @AdaptyActor
    static var observerModeEnabled: Bool?
}
