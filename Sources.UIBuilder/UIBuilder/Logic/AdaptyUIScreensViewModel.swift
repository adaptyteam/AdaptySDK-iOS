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

    var isRightToLeft: Bool { viewConfiguration.isRightToLeft }

    @Published
    private(set) var navigatorsViewModels: [AdaptyUINavigatorViewModel]

    package init(
        logId: String,
        viewConfiguration: AdaptyUIConfiguration
    ) {
        self.logId = logId
        self.viewConfiguration = viewConfiguration
        navigatorsViewModels = []
    }

    func present(
        screen: VS.ScreenInstance,
        transitionId: String,
        completion: (() -> Void)?
    ) {
        Log.ui.verbose("#\(logId)# present screen:\(screen.id) in navigator:\(screen.navigatorId)")

        guard let navigatorConfig = viewConfiguration.navigator(id: screen.navigatorId) else {
            Log.ui.warn("#\(logId)# failed to present screen:\(screen.id) in navigator:\(screen.navigatorId) (navigator not found)")
            return // TODO: x error?
        }

        let screen = AdaptyUIScreenInstance(instance: screen)

        if let navigatorVM = navigatorsViewModels.first(where: { $0.id == navigatorConfig.id }) {
            navigatorVM.startScreenTransition(
                screen,
                transitionId: transitionId,
                completion: completion
            )
        } else {
            // Create new Navigator
            let navigatorVM = AdaptyUINavigatorViewModel(
                navigator: navigatorConfig,
                screen: screen,
                appearTransitionId: transitionId
            )

            navigatorsViewModels.append(navigatorVM)

            navigatorVM.startNavigatorTransition(
                transitionId: transitionId,
                completion: completion
            )
        }
    }

    func dismiss(
        navigatorId: String,
        transitionId: String,
        completion: (() -> Void)?
    ) {
        Log.ui.verbose("#\(logId)# dismiss navigator:\(navigatorId)")

        guard let index = navigatorsViewModels.firstIndex(where: { $0.id == navigatorId }) else {
            Log.ui.error("#\(logId)# failed to dismiss navigator:\(navigatorId) (navigator not found)")

            return
        }

        let navigatorVM = navigatorsViewModels[index]

        navigatorVM.startNavigatorTransition(
            transitionId: transitionId,
            completion: { [weak self] in
                guard let self else { return }
                self.navigatorsViewModels.remove(at: index)

                Log.ui.verbose("#\(self.logId)# dismiss navigator:\(navigatorId) DONE")
                completion?()
            }
        )
    }
}

#endif
