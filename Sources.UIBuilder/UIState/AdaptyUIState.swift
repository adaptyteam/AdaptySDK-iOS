//
//  AdaptyUIState.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 12.12.2025.
//

import Combine
import Foundation

package typealias VS = AdaptyUIState

@MainActor
package final class AdaptyUIState: ObservableObject {
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

    func debug(path: String, filter: VS.DebugFilter = .withoutFunction) -> String {
        jsState.debug(path: path, filter: filter)
    }

    func debug(path: [String] = [], filter: VS.DebugFilter = .withoutFunction) -> String {
        jsState.debug(path: path.joined(separator: "."), filter: filter)
    }

    func debug(variable: VC.Variable, screenInstance: VS.ScreenInstance? = nil, filter: VS.DebugFilter = .withoutFunction) -> String {
        jsState.debug(variable: variable, screenInstance: screenInstance, filter: filter)
    }

    func getValue<T: JSValueRepresentable>(_ type: T.Type, variable: VC.Variable, screenInstance: VS.ScreenInstance) throws(VS.Error) -> T? {
        try jsState.getValue(type, variable: variable, screenInstance: screenInstance)
    }

    func setValue(variable: VC.Variable, value: any JSValueConvertable, screenInstance: VS.ScreenInstance) throws(VS.Error) {
        try jsState.setValue(variable: variable, value: value, screenInstance: screenInstance)
    }

    func execute(actions: [VC.Action], screenInstance: VS.ScreenInstance) throws(VS.Error) {
        try jsState.execute(actions: actions, screenInstance: screenInstance)
    }
}
