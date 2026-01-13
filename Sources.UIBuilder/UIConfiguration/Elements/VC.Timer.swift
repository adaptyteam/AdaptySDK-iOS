//
//  VC.Timer.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 01.05.2024
//

import Foundation

package extension VC {
    struct Timer: Sendable, Hashable {
        package let id: String
        package let state: State
        package let format: Format
        package let actions: [Action]
        package let horizontalAlign: VC.HorizontalAlignment
    }
}
