//
//  VC.Rive.swift
//  AdaptyUIBuilder
//
//  Proof of concept: model for the Rive animation element.
//

import Foundation

extension VC {
    struct Rive: Sendable {
        let animationId: String
        /// Optional artboard name. `nil` → the file's default artboard.
        let artboard: String?
        /// Optional state machine name. `nil` → the artboard's default state machine.
        let stateMachine: String?
        let fit: AdaptyUIRiveFit
        let autoplay: Bool
        /// Data-binding values injected into the view model by path, e.g. ["health": 25].
        let values: [String: AdaptyUIRiveValue]
        /// View-model trigger paths fired once on load, e.g. ["gameOver"].
        let triggers: [String]
    }
}
