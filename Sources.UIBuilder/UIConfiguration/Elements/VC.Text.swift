//
//  VC.Text.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 01.05.2024
//

import Foundation

package extension VC {
    struct Text: Sendable, Hashable {
        package let value: Value
        package let horizontalAlign: HorizontalAlignment
        package let maxRows: Int?
        package let overflowMode: Set<OverflowMode>
        package let defaultTextAttributes: RichText.Attributes?

    }
}
