//
//  VC.Element.Properties.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

extension VC.Element {
    struct Properties: Sendable, Hashable {
        let decorator: VC.Decorator?
        let padding: VC.EdgeInsets
        let offset: VC.Offset?
        let rotation: VC.Rotation?
        let scale: VC.Scale?

        let opacity: Double

        let background: [VC.AlignedElement]?
        let overlay: [VC.AlignedElement]?

        let eventHandlers: [VC.EventHandler]
        let focusId: String?
        let interactionEnabled: VC.Variable?
    }
}

extension VC.Element.Properties {
    @inlinable
    var isEmpty: Bool {
        decorator == .none
            && padding.isZero
            && offset?.isZero ?? true
            && rotation?.isZero ?? true
            && scale?.isEmpty ?? true
            && opacity == 1.0
            && background?.isEmpty ?? true
            && overlay?.isEmpty ?? true
            && eventHandlers.isEmpty
            && focusId == .none
            && interactionEnabled == .none
    }

    @available(*, deprecated, message: "Use eventHandlers instead.")
    var onAppear: [VC.Animation] {
        eventHandlers.filter {
            $0.animations.isNotEmpty && $0.triggers.contains(where: { trigger in
                trigger.filter == nil && trigger.screenTransitions == nil && trigger.events.contains(.onWillAppiar)
            })
        }.flatMap(\.animations)
    }
}

