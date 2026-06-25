//
//  PluginObserverModeResolver.swift
//  AdaptyPlugin
//

#if canImport(UIKit)

    import Adapty
    import AdaptyUI

    /// Bridges flow Observer Mode purchase/restore to the cross-platform host.
    /// Each native-initiated purchase/restore registers `start`/`finish` lifecycle
    /// callbacks in `HostRequestRegistry`, keyed by `event_id`; the host drives
    /// them via the `observer_*` requests and releases on `*_finish`.
    ///
    /// One instance is created per flow view. The owning view's identity is
    /// late-bound by the plugin via `identityBox` (`AdaptyFlowUIView.init` fills
    /// the box once the instance id is known), so the public
    /// `AdaptyObserverModeResolver` protocol stays free of view parameters while
    /// every emitted event still carries its originating view.
    ///
    /// `AdaptyObserverModeResolver` is a `Sendable` protocol with synchronous
    /// requirements, so the conformance cannot be main-actor-isolated. The two
    /// requirements are nevertheless only ever invoked from the main actor (the
    /// rendering layer's `AdaptyUIBuilderLogic` is `@MainActor`), so we hop into
    /// the main actor via `assumeIsolated` to touch `HostRequestRegistry.shared`,
    /// the `@MainActor` lifecycle closures, and `identityBox`. `identityBox` is
    /// likewise only ever read/written on the main actor, hence `@unchecked Sendable`.
    final class PluginObserverModeResolver: AdaptyObserverModeResolver, @unchecked Sendable {
        let eventHandler: EventHandler
        var identityBox: FlowViewIdentityBox?

        init(eventHandler: EventHandler) {
            self.eventHandler = eventHandler
        }

        @MainActor
        private var currentView: AdaptyUI.FlowView {
            identityBox?.value ?? AdaptyUI.FlowView(id: "", placementId: "", variationId: "")
        }

        nonisolated func observerMode(
            didInitiatePurchase product: AdaptyPaywallProduct,
            onStartPurchase: @MainActor @Sendable @escaping () -> Void,
            onFinishPurchase: @MainActor @Sendable @escaping () -> Void
        ) {
            MainActor.assumeIsolated {
                let eventId = HostRequestRegistry.shared.nextEventId()
                HostRequestRegistry.shared.registerCallbacks(eventId, [
                    "purchase_start": onStartPurchase,
                    "purchase_finish": onFinishPurchase,
                ])
                eventHandler.handle(event: FlowViewEvent.ObserverDidInitiatePurchase(
                    view: currentView,
                    eventId: eventId,
                    product: Response.AdaptyPluginPaywallProduct(product)
                ))
            }
        }

        nonisolated func observerModeDidInitiateRestorePurchases(
            onStartRestore: @MainActor @Sendable @escaping () -> Void,
            onFinishRestore: @MainActor @Sendable @escaping () -> Void
        ) {
            MainActor.assumeIsolated {
                let eventId = HostRequestRegistry.shared.nextEventId()
                HostRequestRegistry.shared.registerCallbacks(eventId, [
                    "restore_start": onStartRestore,
                    "restore_finish": onFinishRestore,
                ])
                eventHandler.handle(event: FlowViewEvent.ObserverDidInitiateRestore(
                    view: currentView,
                    eventId: eventId
                ))
            }
        }
    }

#endif
