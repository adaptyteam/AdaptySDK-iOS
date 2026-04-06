//
//  VC.EventHandler.EvenetId.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 06.04.2026.
//

extension VC.EventHandler {
    enum EventId : Sendable, Hashable{
        case onWillAppiar
        case onWillDisapper
        case onDidAppiar
        case onDidDisapper
        case custom(String)
    }
}
