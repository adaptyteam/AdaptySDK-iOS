//
//  VC.Column.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 23.05.2024
//

import Foundation

package extension VC {
    struct Column: Sendable, Hashable {
        package let spacing: Double
        package let items: [GridItem]
    }
}
