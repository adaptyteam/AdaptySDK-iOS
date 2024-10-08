//
//  AdaptyPaywallViewModel.swift
//
//
//  Created by Aleksey Goncharov on 27.06.2024.
//

#if canImport(UIKit)

import Adapty
import Foundation

@available(iOS 15.0, *)
@MainActor // TODO: swift 6
package final class AdaptyPaywallViewModel: ObservableObject {
    let logId: String
    let eventsHandler: AdaptyEventsHandler

    @Published var paywall: AdaptyPaywallInterface
    @Published var viewConfiguration: AdaptyUI.LocalizedViewConfiguration

    var onViewConfigurationUpdate: ((AdaptyUI.LocalizedViewConfiguration) -> Void)?

    package init(
        eventsHandler: AdaptyEventsHandler,
        paywall: AdaptyPaywallInterface,
        viewConfiguration: AdaptyUI.LocalizedViewConfiguration
    ) {
        self.logId = eventsHandler.logId
        self.eventsHandler = eventsHandler
        self.paywall = paywall
        self.viewConfiguration = viewConfiguration
    }

    func logShowPaywall() async {
        let logId = logId
        Log.ui.verbose("#\(logId)# logShowPaywall begin")

        // TODO: swift 6
        do {
            try await paywall.logShowPaywall(viewConfiguration: viewConfiguration)
            Log.ui.verbose("#\(logId)# logShowPaywall success")
        } catch {
            Log.ui.error("#\(logId)# logShowPaywall fail: \(error)")
        }
    }

    func reloadData() async {
        guard let placementId = paywall.id else { return }

        do {
            Log.ui.verbose("#\(logId)# paywall reloadData begin")

            let paywall = try await Adapty.getPaywall(placementId: placementId, locale: paywall.locale)
            let viewConfiguration = try await AdaptyUI.getViewConfiguration(forPaywall: paywall)

            self.paywall = paywall
            self.viewConfiguration = viewConfiguration

            onViewConfigurationUpdate?(viewConfiguration)
        } catch {
            Log.ui.error("#\(logId)# paywall reloadData fail: \(error)")
        }
    }
}

#endif
