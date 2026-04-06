//
//  VC.EventHandler.swift
//  AdaptyUIBulder
//
//  Created by Aleksei Valiano on 06.04.2026.
//

extension VC {
    struct EventHandler: Sendable, Hashable {
        let triggers: [Trigger]
        let animations: [Animation]
        let onAnimationsFinish: [Action]
        let actions: [Action]
    }
}


