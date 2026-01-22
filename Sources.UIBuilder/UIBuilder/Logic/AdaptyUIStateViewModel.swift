//
//  AdaptyUIStateViewModel.swift
//  Adapty
//
//  Created by Alexey Goncharov on 12/17/25.
//

import Combine
import Foundation
import SwiftUI

@MainActor
package final class AdaptyUIStateViewModel: ObservableObject {
    let logId: String
    let isInspectable: Bool
    let state: AdaptyUIState

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
    
    func createBinding<T: JSValueRepresentable>(
        _ variable: VC.Variable,
        defaultValue: T
    ) -> Binding<T> {
        Binding(
            get: { [weak self] in
                guard let self else { return defaultValue }
                
                do {
                    let value = try self.state.getValue(T.self, variable: variable)
                    return value ?? defaultValue
                } catch {
                    Log.ui.error("#\(self.logId)# getValue error: \(error)")
                    return defaultValue
                }
            },
            set: { [weak self] value in
                guard let self else { return }
                
                do {
                    try self.state.setValue(
                        variable: variable,
                        value: value
                    )
                } catch {
                    Log.ui.error("#\(self.logId)# setValue error: \(error)")
                }
            }
        )
    }
}
