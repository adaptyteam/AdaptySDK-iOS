//
//  AdaptyUIStateViewModel.swift
//  Adapty
//
//  Created by Alexey Goncharov on 12/17/25.
//

import Combine
import Foundation

@MainActor
package final class AdaptyUIStateViewModel: ObservableObject {
    let logId: String

    private let isInspectable: Bool
    private let state: AdaptyUIState

    package var viewConfiguration: VC { state.configuration }
    package let logic: any AdaptyUIBuilderLogic

    private var cancellables = Set<AnyCancellable>()

    package init(
        logId: String,
        logic: AdaptyUIBuilderLogic,
        actionHandler: AdaptyUIActionHandler,
        viewConfiguration: VC,
        isInspectable: Bool
    ) {
        self.logId = logId
        self.isInspectable = isInspectable
        self.logic = logic
        self.state = AdaptyUIState(
            name: "AdaptyJSState_[\(logId)]",
            configuration: viewConfiguration,
            actionHandler: actionHandler,
            isInspectable: true // isInspectable // TODO: fix
        )
    }

    package func start() {
        state.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        state.startOnce()
    }

    func execute(actions: [VC.Action]) {
        do {
            try state.execute(actions: actions)
        } catch {
            Log.ui.error("#\(logId)# execute actions error: \(error)")
        }
    }
}
