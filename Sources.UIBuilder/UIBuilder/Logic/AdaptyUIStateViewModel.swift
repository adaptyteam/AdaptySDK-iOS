//
//  AdaptyUIStateViewModel.swift
//  Adapty
//
//  Created by Alexey Goncharov on 12/17/25.
//

#if canImport(UIKit)

import Combine
import Foundation
import SwiftUI

@MainActor
package final class AdaptyUIStateViewModel: ObservableObject {
    let logId: String
    let stateHolder: AdaptyUIStateHolder

    package var viewConfiguration: VC { stateHolder.state.configuration }
    package let logic: any AdaptyUIBuilderLogic

    private var cancellables = Set<AnyCancellable>()

    @Published var focusedId: String?

    package init(
        logId: String,
        logic: AdaptyUIBuilderLogic,
        stateHolder: AdaptyUIStateHolder
    ) {
        self.logId = logId
        self.logic = logic
        self.stateHolder = stateHolder

        stateHolder.state.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    func handle(url: URL, screen: VS.ScreenInstance?) -> Bool {
        do {
            let action = try VC.Action(url: url)

            if let screen {
                execute(actions: [action], screen: screen)
            } else {
                Log.ui.warn("#\(logId)# cant handle action url because there is no current screen!")
            }
            return true
        } catch {
            Log.ui.error("#\(logId)# handle action url error: \(error)")
            return false
        }
    }

    func execute(actions: [VC.Action], additionalParams: [String: VC.Parameter]? = nil, screen: VS.ScreenInstance) {
        do {
            try stateHolder.state.execute(actions: actions, additionalParams: additionalParams, screenInstance: screen)
        } catch {
            Log.ui.error("#\(logId)# execute actions error: \(error)")
        }
    }

    func fireFocusChangeActions(
        oldFocusId: String?,
        newFocusId: String?,
        actions: [VC.Action],
        screen: VS.ScreenInstance
    ) {
        var additionalParams: [String: VC.Parameter] = [:]
        if let newFocusId {
            additionalParams["focus_id"] = .string(newFocusId)
        }
        if let oldFocusId {
            additionalParams["old_focus_id"] = .string(oldFocusId)
        }

        execute(
            actions: actions,
            additionalParams: additionalParams.isEmpty ? nil : additionalParams,
            screen: screen
        )
    }

    func getValue<T: JSValueRepresentable & JSValueConvertable>(
        _ variable: VC.Variable,
        defaultValue: T,
        screen: VS.ScreenInstance
    ) -> T {
        do {
            let value = try stateHolder.state.getValue(
                T.self,
                variable: variable,
                screenInstance: screen
            )
            return value ?? defaultValue
        } catch {
            Log.ui.error("#\(logId)# getValue error: \(error)")
            return defaultValue
        }
    }

    func createBinding<T: JSValueRepresentable & JSValueConvertable>(
        _ variable: VC.Variable,
        defaultValue: T,
        screen: VS.ScreenInstance
    ) -> Binding<T> {
        Binding(
            get: { [weak self] in
                guard let self else { return defaultValue }

                do {
                    let value = try stateHolder.state.getValue(
                        T.self,
                        variable: variable,
                        screenInstance: screen
                    )
                    return value ?? defaultValue
                } catch {
                    Log.ui.error("#\(logId)# getValue error: \(error)")
                    return defaultValue
                }
            },
            set: { [weak self] value in
                guard let self else { return }

                do {
                    try stateHolder.state.setValue(
                        variable: variable,
                        value: value,
                        screenInstance: screen
                    )
                } catch {
                    Log.ui.error("#\(logId)# setValue error: \(error)")
                }
            }
        )
    }
}

#endif
