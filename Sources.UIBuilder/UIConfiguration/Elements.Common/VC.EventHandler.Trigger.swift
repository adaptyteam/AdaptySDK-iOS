//
//  VC.EventHandler.Trigger.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 06.04.2026.
//

extension VC.EventHandler {
    struct Trigger: Sendable, Hashable {
        let events: [EventId]
        let filter: Filter?
        let screenTransitions: [String]?
    }
}



