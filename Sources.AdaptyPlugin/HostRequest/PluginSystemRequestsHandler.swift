//
//  PluginSystemRequestsHandler.swift
//  AdaptyPlugin
//

#if canImport(UIKit)

    import AdaptyUIBuilder

    /// Bridges flow system requests to the cross-platform host:
    /// permissions round-trip through `HostRequestRegistry`; app review is fire-and-forget.
    @MainActor
    struct PluginSystemRequestsHandler: AdaptyUISystemRequestsHandler {
        let eventHandler: EventHandler

        func handlePermission(
            _ permission: AdaptyUIPermission,
            withCustomArgs customArgs: [String: String]?
        ) async -> AdaptyUIPermissionResult {
            let resolution: PermissionResolution? = await HostRequestRegistry.shared.perform { requestId in
                eventHandler.handle(event: Event.DidRequestPermission(
                    requestId: requestId,
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
            eventHandler.handle(event: Event.DidRequestAppReview())
        }
    }

#endif
