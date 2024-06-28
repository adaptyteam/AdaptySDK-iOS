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
package class AdaptyPaywallViewModel: ObservableObject {
    let eventsHandler: AdaptyEventsHandler
    
    @Published var paywall: AdaptyPaywallInterface
    @Published var viewConfiguration: AdaptyUI.LocalizedViewConfiguration

    var onViewConfigurationUpdate: ((AdaptyUI.LocalizedViewConfiguration) -> Void)?

    package init(
        eventsHandler: AdaptyEventsHandler,
        paywall: AdaptyPaywallInterface,
        viewConfiguration: AdaptyUI.LocalizedViewConfiguration
    ) {
        self.eventsHandler = eventsHandler
        self.paywall = paywall
        self.viewConfiguration = viewConfiguration
    }

    func logShowPaywall() {
        eventsHandler.log(.verbose, "logShowPaywall begin")
        
        paywall.logShowPaywall(viewConfiguration: viewConfiguration) { [weak self] error in
            if let error {
                self?.eventsHandler.log(.error, "logShowPaywall fail: \(error)")
            } else {
                self?.eventsHandler.log(.verbose, "logShowPaywall success")
            }
        }
    }

    func reloadData() {
        guard let placementId = paywall.id else { return }
        
        Task { @MainActor in
            do {
                eventsHandler.log(.verbose, "paywall reloadData begin")
                
                let paywall = try await Adapty.getPaywall(placementId: placementId, locale: paywall.locale)
                let viewConfiguration = try await AdaptyUI.getViewConfiguration(forPaywall: paywall)
                
                self.paywall = paywall
                self.viewConfiguration = viewConfiguration
                
                onViewConfigurationUpdate?(viewConfiguration)
            } catch {
                eventsHandler.log(.error, "paywall reloadData fail: \(error)")
            }
        }
    }
}

#endif
