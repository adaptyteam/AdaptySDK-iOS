//
//  AdaptyUIState.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 12.12.2025.
//

import Combine
import Foundation

typealias VS = AdaptyUIState

@MainActor
final class AdaptyUIState: ObservableObject {
    let configuration: AdaptyUIConfiguration
    private let jsState: VS.JSState

    private(set) var started: Bool = false

    private var cancellables = Set<AnyCancellable>()

    init(
        name: String = "AdaptyJSState",
        configuration: AdaptyUIConfiguration,
        actionHandler: AdaptyUIActionHandler? = nil,
        isInspectable: Bool = false
    ) {
        self.configuration = configuration
        self.jsState = .init(
            name: name,
            isInspectable: isInspectable,
            actionHandler: actionHandler
        )

        jsState.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    func startOnce() {
        guard !started else { return }
        started = true
        jsState.evaluateScripts(configuration.scripts)
    }

    func getValue<T: JSValueRepresentable>(_ type: T.Type, variable: VC.Variable, screenInstance: VC.ScreenInstance) throws(VS.Error) -> T? {
        try jsState.getValue(type, variable: variable, screenInstance: screenInstance)
    }

    func setValue(variable: VC.Variable, value: any JSValueRepresentable, screenInstance: VC.ScreenInstance) throws(VS.Error) {
        try jsState.setValue(variable: variable, value: value, screenInstance: screenInstance)
    }

    func execute(actions: [VC.Action], screenInstance: VC.ScreenInstance) throws(VS.Error) {
        try jsState.execute(actions: actions, screenInstance: screenInstance)
    }
}
