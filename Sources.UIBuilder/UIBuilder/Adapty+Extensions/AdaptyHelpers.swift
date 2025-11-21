//
//  Collection+Extension.swift
//  AdaptyUIBuilder
//
//  Created by Aleksey Goncharov on 12.06.2024.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
