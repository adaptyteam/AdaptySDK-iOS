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

        jsState.evaluateScripts([])
    }

    func getValue<T: JSValueRepresentable>(_ type: T.Type, _ key: String) throws(VS.Error) -> T? {
        try jsState.getValue(type, key)
    }

    func setValue(_ key: String, _ value: any JSValueRepresentable) throws(VS.Error) {
        try jsState.setValue(key, value)
    }

    func execute(actions: [VC.Action]) {
        try jsState.execute(actions: actions)
    }
}
