//
//  AdaptyPaywallViewModel.swift
//
//
//  Created by Aleksey Goncharov on 27.06.2024.
//

#if canImport(UIKit)

import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
package final class AdaptyPaywallViewModel: ObservableObject {
    let logId: String
    let logic: any AdaptyUIBuilderLogic

    @Published package var paywall: AdaptyPaywallModel
    @Published package var viewConfiguration: AdaptyUIConfiguration

    var onViewConfigurationUpdate: ((AdaptyUIConfiguration) -> Void)?

    package init(
        logId: String,
        logic: AdaptyUIBuilderLogic,
        paywall: AdaptyPaywallModel,
        viewConfiguration: AdaptyUIConfiguration
    ) {
        self.logId = logId
        self.logic = logic
        self.paywall = paywall
        self.viewConfiguration = viewConfiguration
    }

    private var logShowPaywallCalled = false

    func reportDidFailRendering(with error: AdaptyUIBuilderError) {}

    package func logShowPaywall() {
        guard !logShowPaywallCalled else { return }
        logShowPaywallCalled = true

        let logId = logId
        Log.ui.verbose("#\(logId)# logShowPaywall begin")

        Task {
            do {
                try await logic.logShowPaywall(
                    paywall: paywall,
                    viewConfiguration: viewConfiguration
                )
                Log.ui.verbose("#\(logId)# logShowPaywall success")
            } catch {
                Log.ui.error("#\(logId)# logShowPaywall fail: \(error)")
            }
        }
    }

    package func resetLogShowPaywall() {
        Log.ui.verbose("#\(logId)# resetLogShowPaywall")
        logShowPaywallCalled = false
    }

    func reloadData() {
        Task { @MainActor in
            do {
                Log.ui.verbose("#\(logId)# paywall reloadData begin")

                let paywall = try await logic.getPaywall(placementId: paywall.placementId, locale: paywall.locale)
                let viewConfiguration = try await logic.getViewConfiguration(paywall: paywall)

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
