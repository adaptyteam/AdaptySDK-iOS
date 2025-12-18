//
//  AdaptyUIPaywallViewModel.swift
//  AdaptyUIBuilder
//
//  Created by Aleksey Goncharov on 27.06.2024.
//

#if canImport(UIKit)

import Foundation

@MainActor
package final class AdaptyUIPaywallViewModel: ObservableObject {
    let logId: String
    package let logic: any AdaptyUIBuilderLogic

    @Published package var viewConfiguration: AdaptyUIConfiguration

    package init(
        logId: String,
        logic: AdaptyUIBuilderLogic,
        viewConfiguration: AdaptyUIConfiguration
    ) {
        self.logId = logId
        self.logic = logic
        self.viewConfiguration = viewConfiguration
    }

    private var logShowPaywallCalled = false

    func reportDidFailRendering(with error: AdaptyUIBuilderError) {
        logic.reportDidFailRendering(with: error)
    }

    package func logShowPaywall() {
        guard !logShowPaywallCalled else { return }
        logShowPaywallCalled = true

        let logId = logId
        Log.ui.verbose("#\(logId)# logShowPaywall begin")

        Task {
            do {
                try await logic.logShowPaywall(
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
}

#endif
