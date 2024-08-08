//
//  AdaptyHelpers.swift
//
//
//  Created by Aleksey Goncharov on 12.06.2024.
//

import Foundation

extension Collection where Indices.Iterator.Element == Index {
    subscript(safe index: Index) -> Iterator.Element? {
        (startIndex <= index && index < endIndex) ? self[index] : nil
    }
}

public struct AdaptyIdentifiablePlaceholder: Identifiable {
    public var id: String { "placeholder" }
}
