//
//  Adapty.swift
//  AdaptySDK
//
//  Created by Andrey Kyashkin on 28.10.2019.
//

import StoreKit

#if canImport(UIKit)
    import UIKit
#endif

private let log = Log.default

extension Adapty {
    public nonisolated static var isActivated: Bool { shared != nil }

    static let profileIdentifierStorage: ProfileIdentifierStorage = UserDefaults.standard

    /// Use this method to initialize the Adapty SDK.
    ///
    /// Call this method in the `application(_:didFinishLaunchingWithOptions:)`.
    ///
    /// - Parameter configuration: `Adapty.Configuration` which allows to configure Adapty SDK
    /// - Parameter completion: Result callback
    public nonisolated static func activate(
        with configuration: Adapty.Configuration,
        _ completion: AdaptyErrorCompletion? = nil
    ) {
        let logName = "activate"
        let logParams: EventParameters = [
            "observer_mode": configuration.observerMode,
            "has_customer_user_id": configuration.customerUserId != nil,
            "idfa_collection_disabled": configuration.idfaCollectionDisabled,
            "ip_address_collection_disabled": configuration.ipAddressCollectionDisabled,
        ]

        async(completion, logName: logName, logParams: logParams) { completion in
            if isActivated {
                let err = AdaptyError.activateOnceError()
                log.warn("Adapty activate error \(err)")
                completion(err)
                return
            }

            UserDefaults.standard.clearAllDataIfDifferent(apiKey: configuration.apiKey)

            Adapty.dispatchQueue = configuration.dispatchQueue
            Configuration.idfaCollectionDisabled = configuration.idfaCollectionDisabled
            Configuration.ipAddressCollectionDisabled = configuration.ipAddressCollectionDisabled
            Configuration.observerMode = configuration.observerMode

            let backend = Backend(with: configuration)

            Adapty.eventsManager = EventsManager(profileStorage: UserDefaults.standard, backend: backend)

            shared = Adapty(
                apiKeyPrefix: String(configuration.apiKey.prefix(while: { $0 != "." })),
                profileStorage: UserDefaults.standard,
                vendorIdsStorage: UserDefaults.standard,
                backend: backend,
                customerUserId: configuration.customerUserId
            )

            LifecycleManager.shared.initialize()

            log.info("Adapty activated withObserverMode:\(configuration.observerMode), withCustomerUserId: \(configuration.customerUserId != nil)")
            completion(nil)
        }
    }
}
