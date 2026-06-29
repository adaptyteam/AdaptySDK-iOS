//
//  PluginSystemRequestsHandler.swift
//  AdaptyPlugin
//

#if canImport(UIKit)

    import AdaptyUI
    import AdaptyUIBuilder

    /// Bridges flow system requests to the cross-platform host:
    /// permissions round-trip through `HostRequestRegistry`; app review is fire-and-forget.
    ///
    /// One instance is created per flow view. The owning view's identity is
    /// late-bound by the plugin via `identityBox` (see `FlowViewIdentityBox`), so
    /// the public `AdaptyUISystemRequestsHandler` protocol stays free of view
    /// parameters while every emitted event still carries its originating view.
    @MainActor
    final class PluginSystemRequestsHandler: AdaptyUISystemRequestsHandler {
        let eventHandler: EventHandler
        var identityBox: FlowViewIdentityBox?

        init(eventHandler: EventHandler) {
            self.eventHandler = eventHandler
        }

        private var currentView: AdaptyUI.FlowView {
            identityBox?.value ?? AdaptyUI.FlowView(id: "", placementId: "", variationId: "")
        }

        func handlePermission(
            _ permission: AdaptyUIPermission,
            withCustomArgs customArgs: [String: String]?
        ) async -> AdaptyUIPermissionResult {
            let view = currentView
            let resolution: PermissionResolution? = await HostRequestRegistry.shared.perform { eventId in
                eventHandler.handle(event: FlowViewEvent.DidAskPermission(
                    view: view,
                    eventId: eventId,
                    permission: permission.wireValue,
                    customArgs: customArgs
                ))
            }

            switch resolution?.status {
            case .granted: return .granted(resolution?.detail)
            case .denied: return .denied(resolution?.detail)
            case .unavailable: return .denied(resolution?.detail ?? "unavailable")
            case nil: return .denied("cancelled") // flushed on teardown
            }
        }

        func handleAppReviewRequest() async {
            eventHandler.handle(event: FlowViewEvent.DidRequestAppReview(
                view: currentView
            ))
        }
    }

#endif
