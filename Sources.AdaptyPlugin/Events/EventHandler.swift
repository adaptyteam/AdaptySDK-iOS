//
//  Event.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 20.11.2024.
//

import Adapty
import AdaptyUI

public protocol EventHandler: Sendable {
    func handle(event: AdaptyPluginEvent)
}

enum Event {}

public extension AdaptyPlugin {
    @MainActor
    private static var delegate: AdaptyPluginDelegate?

    @MainActor
    static var sharedEventHandler: EventHandler? { delegate?.eventHandler }

    @MainActor
    static func register(eventHandler: EventHandler) {
        HostRequestRegistry.shared.flushCancelled()
        let delegate = AdaptyPluginDelegate(eventHandler: eventHandler)
        self.delegate = delegate
        Adapty.delegate = delegate

#if canImport(UIKit)
        AdaptyUI.universalDelegate = delegate
#endif
    }
}
