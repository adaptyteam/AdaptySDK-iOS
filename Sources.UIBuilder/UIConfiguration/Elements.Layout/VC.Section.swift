//
//  VC.Section.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 23.05.2024
//

import Foundation

package extension VC {
    struct Section: Sendable, Hashable {
        package let id: String
        package let index: Int32
        package let content: [Element]
    }
}
