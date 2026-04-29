//
//  VC.Text.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 01.05.2024
//

import Foundation

extension VC {
    struct Text: Sendable {
        let value: StringReference
        let horizontalAlign: HorizontalAlignment
        let maxRows: Int?
        let overflowMode: Set<OverflowMode>
        let defaultTextAttributes: VC.TextAttributes?
    }
}
