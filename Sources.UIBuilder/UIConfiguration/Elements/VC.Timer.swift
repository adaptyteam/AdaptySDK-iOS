//
//  VC.Timer.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 01.05.2024
//

import Foundation

extension VC {
    struct Timer: Sendable, Hashable {
        let id: String
        let state: State
        let format: VC.RangeTextFormat
        let actions: [Action]
        let horizontalAlign: VC.HorizontalAlignment
    }
}
