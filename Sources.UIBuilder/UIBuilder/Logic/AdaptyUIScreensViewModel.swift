//
//  AdaptyUIScreensViewModel.swift
//  AdaptyUIBuilder
//
//  Created by Aleksey Goncharov on 18.06.2024.
//

#if canImport(UIKit)

import Foundation

extension VC {
    func navigator(id: String) -> Navigator? {
        navigators[id] ?? navigators["default"]
    }
}

@MainActor
package final class AdaptyUIScreensViewModel: ObservableObject {
    private let logId: String
    private let viewConfiguration: VC

    var isRightToLeft: Bool { rtlOverride ?? viewConfiguration.isRightToLeft }

    var showPurchaseLoader: Bool { viewConfiguration.showPurchaseLoader }
    var showRestoreLoader: Bool { viewConfiguration.showRestoreLoader }

    private let rtlOverride: Bool?

    @Published
    private(set) var navigatorsViewModels: [AdaptyUINavigatorViewModel]

    private var dismissingNavigatorIds: Set<String> = []

    package init(
        logId: String,
        viewConfiguration: AdaptyUIConfiguration,
        rtlOverride: Bool? = nil
    ) {
        self.logId = logId
        self.rtlOverride = rtlOverride
        self.viewConfiguration = viewConfiguration
        navigatorsViewModels = []
    }

    /// Set by state action handler to enable screen lifecycle action execution
    var executeActions: ((_ actions: [VC.Action], _ screen: VS.ScreenInstance) -> Void)?

    /// Set by state action handler to surface navigation errors to the logic layer
    var reportError: ((AdaptyUIBuilderError) -> Void)?

    var topmostScreenInstance: VS.ScreenInstance? {
        navigatorsViewModels.max(by: { $0.order < $1.order })?.screens.last?.instance
    }

    func present(
        screen: VS.ScreenInstance,
        transitionId: String,
        completion: (() -> Void)?
    ) {
        Log.ui.verbose("#\(logId)# present screen:\(screen.id) in navigator:\(screen.navigatorId)")

        guard let navigatorConfig = viewConfiguration.navigator(id: screen.navigatorId) else {
            Log.ui.error("#\(logId)# failed to present screen:\(screen.id) in navigator:\(screen.navigatorId) (navigator not found)")
            reportError?(.navigatorNotFound(screen.navigatorId))
            return
        }

        let screen = AdaptyUIScreenViewModel(instance: screen)

        if let navigatorVM = navigatorsViewModels.first(where: { $0.id == navigatorConfig.id }) {
            navigatorVM.startScreenTransition(
                screen,
                transitionId: transitionId,
                completion: completion
            )
        } else {
            // Create new Navigator
            let navigatorVM = AdaptyUINavigatorViewModel(
                logId: logId,
                navigator: navigatorConfig,
                screen: screen,
                appearTransitionId: transitionId
            )

            navigatorVM.executeActions = executeActions
            navigatorsViewModels.append(navigatorVM)

            navigatorVM.startNavigatorTransition(
                transitionId: transitionId,
                completion: completion
            )
        }
    }

    package func prepareForReuse() {
        Log.ui.verbose("#\(logId)# prepareForReuse")
        navigatorsViewModels.removeAll()
        dismissingNavigatorIds.removeAll()
    }

    func dismiss(
        navigatorId: String,
        transitionId: String,
        completion: (() -> Void)?
    ) {
        Log.ui.verbose("#\(logId)# dismiss navigator:\(navigatorId)")

        guard !dismissingNavigatorIds.contains(navigatorId) else {
            Log.ui.warn("#\(logId)# dismiss navigator:\(navigatorId) ignored (already dismissing)")
            return
        }

        guard let navigatorVM = navigatorsViewModels.first(where: { $0.id == navigatorId }) else {
            Log.ui.error("#\(logId)# failed to dismiss navigator:\(navigatorId) (navigator not found)")

            return
        }

        dismissingNavigatorIds.insert(navigatorId)

        navigatorVM.publishDismissEvents()

        navigatorVM.startNavigatorTransition(
            transitionId: transitionId,
            completion: { [weak self] in
                guard let self else { return }

                // Fire onDidDisappear for the navigator's screens
                if let screen = navigatorVM.screens.last {
                    navigatorVM.executeScreenActions(.onDidDisappear, screen: screen.instance)
                }

                self.dismissingNavigatorIds.remove(navigatorId)

                if let index = self.navigatorsViewModels.firstIndex(where: { $0.id == navigatorId }) {
                    self.navigatorsViewModels.remove(at: index)
                }

                Log.ui.verbose("#\(self.logId)# dismiss navigator:\(navigatorId) DONE")
                completion?()
            }
        )
    }
}

#endif
