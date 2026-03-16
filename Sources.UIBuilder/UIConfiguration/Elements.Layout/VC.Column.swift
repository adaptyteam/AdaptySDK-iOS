//
//  VC.Column.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 23.05.2024
//

import Foundation

extension VC {
    struct Column: Sendable, Hashable {
        let spacing: Double
        let items: [GridItem]
    }
}
