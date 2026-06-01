//
//  AdaptyUIPaywallViewModel.swift
//  AdaptyUIBuilder
//
//  Created by Aleksey Goncharov on 27.06.2024.
//

#if canImport(UIKit)

import Foundation

@MainActor
package final class AdaptyUIFlowViewModel: ObservableObject {
    let logId: String
    package let logic: any AdaptyUIBuilderLogic

    @Published package var viewConfiguration: AdaptyUIConfiguration

    @Published package private(set) var flowStartedAt: Date?

    package init(
        logId: String,
        logic: AdaptyUIBuilderLogic,
        viewConfiguration: AdaptyUIConfiguration
    ) {
        self.logId = logId
        self.logic = logic
        self.viewConfiguration = viewConfiguration
    }

    private var logShowFlowCalled = false

    func reportDidReceiveError(_ error: AdaptyUIBuilderError) {
        logic.reportDidReceiveError(error)
    }

    package func logShowFlow() {
        if flowStartedAt == nil { flowStartedAt = Date() }

        guard viewConfiguration.formatVersion.isLegacyVersion else {
            Log.ui.verbose("#\(logId)# logShowFlow skipped (non-legacy view configuration)")
            return
        }

        guard !logShowFlowCalled else { return }
        logShowFlowCalled = true

        let logId = logId

        Log.ui.verbose("#\(logId)# logShowFlow begin")

        Task {
            do {
                try await logic.logShowFlow()
                Log.ui.verbose("#\(logId)# logShowFlow success")
            } catch {
                Log.ui.error("#\(logId)# logShowFlow fail: \(error)")
            }
        }
    }

    package func prepareForReuse() {
        Log.ui.verbose("#\(logId)# prepareForReuse")
        logShowFlowCalled = false
        flowStartedAt = nil
    }
}

#endif
