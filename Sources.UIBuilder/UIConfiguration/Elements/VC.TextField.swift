//
//  VC.TextField.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 14.01.2026.
//

import Foundation

import Foundation

package extension VC {
    struct TextField: Sendable, Hashable {
        package let value: Variable
        package let horizontalAlign: HorizontalAlignment
        package let maxRows: Int?
        package let overflowMode: Set<Text.OverflowMode>
        package let defaultTextAttributes: RichText.Attributes?
    }
}
