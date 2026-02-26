//
//  Schema.Error.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 15.09.2025.
//

package extension Schema {
    @usableFromInline
    enum Error: Swift.Error {
        case unsupportedElement(String)
        case elementsTreeCycle(String)

        case dublicateLegacyReference(String)
        case notFoundTemplate(String)
    }
}
