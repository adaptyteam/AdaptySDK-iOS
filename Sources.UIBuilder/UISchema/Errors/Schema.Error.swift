//
//  Schema.Error.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 15.09.2025.
//

package extension Schema {
    enum Error: Swift.Error {
        case notFoundAsset(String)
        case wrongTypeAsset(String)

        case unsupportedElement(String)
        case elementsTreeCycle(String)

        case dublicateLegacyReference(String)
        case notFoundTemplate(String)
    }
}
