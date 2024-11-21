//
//  AdaptyPluginDelegate.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 21.11.2024.
//

import Adapty

final class AdaptyPluginDelegate: AdaptyDelegate {
    let eventHandler: EventHandler

    init(eventHandler: EventHandler) {
        self.eventHandler = eventHandler
    }

    func didLoadLatestProfile(_ profile: AdaptyProfile) {
        eventHandler.handle(event: Event.DidLoadLatestProfile(profile: profile))
    }
}
