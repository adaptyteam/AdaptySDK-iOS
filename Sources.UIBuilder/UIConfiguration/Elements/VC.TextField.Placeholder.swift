//
//  VC.TextField.Placeholder.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 12.03.2026.
//

import Foundation

extension VC.TextField {
    struct Placeholder: Sendable {
        let value: VC.StringReference
        let overflowMode: Set<VC.Text.OverflowMode>
        let defaultTextAttributes: VC.TextAttributes?
    }
}
