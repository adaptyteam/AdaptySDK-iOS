//
//  VC.Decorator.Layer.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 23.10.2026.
//

import Foundation

extension VC.Decorator {
    struct Layer: Sendable {
        let id: Int?
        let kind: Kind
        let blend: VC.BlendMode
        let effects: [Shadow]
    }
}
