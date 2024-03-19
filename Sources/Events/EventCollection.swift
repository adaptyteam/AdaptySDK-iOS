//
//  EventCollection.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 07.10.2022.
//

import Foundation

struct EventCollection<Element> {
    private(set) var elements: [Element]
    private(set) var startIndex: Int
    var endIndex: Int { endIndex(elements.count) }
    var isEmpty: Bool { elements.isEmpty }

    func endIndex(_ count: Int) -> Int { startIndex + count - 1 }

    mutating func removeAll() {
        guard !elements.isEmpty else { return }
        startIndex += elements.count
        elements = []
    }

    mutating func removeFirst(_ k: Int) {
        guard k > 0 else { return }
        if k >= elements.count {
            removeAll()
        } else {
            startIndex += k
            elements = Array(elements.dropFirst(k))
        }
    }

    mutating func subtract(newStartIndex: Int) {
        removeFirst(newStartIndex - startIndex)
    }

    mutating func append(_ element: Element) {
        elements.append(element)
    }

    mutating func append(_ element: Element, withLimit: Int) {
        elements.append(element)
        guard withLimit >= 0 else { return }
        removeFirst(elements.count - withLimit)
    }

    mutating func remove(toLimit: Int) {
        guard toLimit >= 0 else { return }
        removeFirst(elements.count - toLimit)
    }
}
