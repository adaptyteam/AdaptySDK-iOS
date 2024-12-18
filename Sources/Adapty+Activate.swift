//
//  Adapty+Activate.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 22.09.2024
//

import Foundation

private let log = Log.default

extension Adapty {
    /// Use this method to initialize the Adapty SDK. It is the caller's responsibility to ensure that this method is
    /// invoked only once. If and only if this requirement is violated, the method throws an appropriate error.
    ///
    /// Call this method in the `application(_:didFinishLaunchingWithOptions:)`.
    ///
    /// - Parameter apiKey: You can find it in your app settings in [Adapty Dashboard](https://app.adapty.io/) *App settings* > *General*.
    /// - Parameter observerMode: A boolean value controlling [Observer mode](https://docs.adapty.io/v2.0.0/docs/observer-vs-full-mode). Turn it on if you handle purchases and subscription status yourself and use Adapty for sending subscription events and analytics
    /// - Parameter customerUserId: User identifier in your system
    ///
    /// - Throws: An `AdaptyError` instance indicating a violation of the requirement to invoke this method only once.
    ///
    /// - important: This method is not thread-safe.
    public nonisolated static func activate(
        _ apiKey: String,
        observerMode: Bool = false,
        customerUserId: String? = nil
    ) async throws {
        try await activate(
            with: AdaptyConfiguration
                .builder(withAPIKey: apiKey)
                .with(customerUserId: customerUserId)
                .with(observerMode: observerMode)
                .build()
        )
    }

    /// Use this method to initialize the Adapty SDK. It is the caller's responsibility to ensure that this method is
    /// invoked only once. If and only if this requirement is violated, the method throws an appropriate error.
    ///
    /// Call this method in the `application(_:didFinishLaunchingWithOptions:)`.
    ///
    /// - Parameter builder: `AdaptyConfiguration.Builder` which allows to configure Adapty SDK
    ///
    /// - Throws: An `AdaptyError` instance indicating a violation of the requirement to invoke this method only once.
    ///
    /// - important: This method is not thread-safe.
    public nonisolated static func activate(
        with builder: AdaptyConfiguration.Builder
    ) async throws {
        try await activate(with: builder.build())
    }

    /// Use this method to initialize the Adapty SDK. It is the caller's responsibility to ensure that this method is
    /// invoked only once. If and only if this requirement is violated, the method throws an appropriate error.
    ///
    /// Call this method in the `application(_:didFinishLaunchingWithOptions:)`.
    ///
    /// - Parameter configuration: `AdaptyConfiguration` which allows to configure Adapty SDK
    ///
    /// - Throws: An `AdaptyError` instance indicating a violation of the requirement to invoke this method only once.
    ///
    /// - important: This method is not thread-safe.
    public static func activate(
        with configuration: AdaptyConfiguration
    ) async throws {
        let stamp = Log.stamp
        let logParams: EventParameters? = [
            "observer_mode": configuration.observerMode,
            "has_customer_user_id": configuration.customerUserId != nil,
            "idfa_collection_disabled": configuration.idfaCollectionDisabled,
            "ip_address_collection_disabled": configuration.ipAddressCollectionDisabled,
        ]

        trackSystemEvent(AdaptySDKMethodRequestParameters(methodName: .activate, stamp: stamp, params: logParams))
        log.verbose("Calling Adapty activate [\(stamp)] with params: \(logParams?.description ?? "nil")")

        guard !isActivated else {
            let error = AdaptyError.activateOnceError()
            trackSystemEvent(AdaptySDKMethodResponseParameters(methodName: .activate, stamp: stamp, error: error.localizedDescription))
            log.error("Adapty activate [\(stamp)] encountered an error: \(error).")
            throw error
        }

        let task = Task<Adapty, Never> { @AdaptyActor in
            if let logLevel = configuration.logLevel { Adapty.logLevel = logLevel }

            await Storage.clearAllDataIfDifferent(apiKey: configuration.apiKey)

            AdaptyConfiguration.callbackDispatchQueue = configuration.callbackDispatchQueue // TODO: Refactoring
            AdaptyConfiguration.idfaCollectionDisabled = configuration.idfaCollectionDisabled // TODO: Refactoring
            AdaptyConfiguration.ipAddressCollectionDisabled = configuration.ipAddressCollectionDisabled // TODO: Refactoring

            let environment = await Environment.instance
            let backend = Backend(with: configuration, envorinment: environment)

            Task {
                await eventsManager.set(backend: backend)
            }

            let sdk = await Adapty(
                configuration: configuration,
                backend: backend
            )

            trackSystemEvent(AdaptySDKMethodResponseParameters(methodName: .activate, stamp: stamp))
            log.info("Adapty activated successfully. [\(stamp)]")

            set(shared: sdk)

            LifecycleManager.shared.initialize()
            return sdk
        }
        set(activatingSDK: task)
        _ = await task.value
    }
}
