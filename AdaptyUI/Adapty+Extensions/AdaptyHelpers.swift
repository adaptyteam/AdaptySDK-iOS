//
//  AdaptyHelpers.swift
//
//
//  Created by Aleksey Goncharov on 12.06.2024.
//

// TODO: AdaptyHelpers.swift не хорошее название файла ,
// в данном файле есть extension для Collection+SafeSubscript
// и объявление  struct AdaptyIdentifiablePlaceholder:
// стоит разбить соотвественно на два файла

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// TODO: Почему public ?
public struct AdaptyIdentifiablePlaceholder: Identifiable {
    public var id: String { "placeholder" }
}
