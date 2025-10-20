//
//  AdaptyPaywallViewModel.swift
//
//
//  Created by Aleksey Goncharov on 27.06.2024.
//

#if canImport(UIKit)

import Adapty
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
package final class AdaptyPaywallViewModel: ObservableObject {
    private var logId: String { eventsHandler.logId }
    let eventsHandler: AdaptyEventsHandler

    @Published var paywall: AdaptyPaywallInterface
    @Published var viewConfiguration: AdaptyViewConfiguration

    var onViewConfigurationUpdate: ((AdaptyViewConfiguration) -> Void)?

    package init(
        eventsHandler: AdaptyEventsHandler,
        paywall: AdaptyPaywallInterface,
        viewConfiguration: AdaptyViewConfiguration
    ) {
        self.eventsHandler = eventsHandler
        self.paywall = paywall
        self.viewConfiguration = viewConfiguration
    }

    private var logShowPaywallCalled = false

    func logShowPaywall() {
        guard !logShowPaywallCalled else { return }
        logShowPaywallCalled = true

        paywall.logShowPaywall()
        Log.ui.verbose("#\(logId)# logShowPaywall")
    }

    func resetLogShowPaywall() {
        Log.ui.verbose("#\(logId)# resetLogShowPaywall")
        logShowPaywallCalled = false
    }

    func reloadData() {
        Task { @MainActor in
            do {
                Log.ui.verbose("#\(logId)# paywall reloadData begin")

                let paywall = try await Adapty.getPaywall(placementId: paywall.placementId, locale: paywall.locale)
                let viewConfiguration = try await Adapty.getViewConfiguration(paywall: paywall)

                self.paywall = paywall
                self.viewConfiguration = viewConfiguration

                onViewConfigurationUpdate?(viewConfiguration)
            } catch {
                Log.ui.error("#\(logId)# paywall reloadData fail: \(error)")
            }
        }
    }
}

#endif
