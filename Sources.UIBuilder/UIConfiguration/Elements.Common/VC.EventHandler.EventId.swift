//
//  VC.EventHandler.EventId.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 06.04.2026.
//

extension VC.EventHandler {
    enum EventId: Sendable, Hashable {
        case onWillAppear
        case onWillDisappear
        case onDidAppear
        case onDidDisappear
        case custom(String)
    }
}
