//
//  AdaptyUISchema.LocalizerError.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 15.09.2025.
//

extension AdaptyUISchema {
    package enum LocalizerError: Swift.Error {
        case notFoundAsset(String)
        case wrongTypeAsset(String)
        case unknownReference(String)
        case referenceCycle(String)
    }
}

