//
//  VS.Error.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 15.12.2025.
//

import Foundation

extension VS {
    enum Error: Swift.Error {
        case referenceWithoutAssetId
        case notFoundAsset(String)
        case wrongTypeAsset(String)

        case jsGlobalObjectNotFound
        case jsPathToObjectIsEmpty
        case jsObjectNotFound(String)
        case jsMethodNotFound(String)

        case notFoundConvertor(String)
    }
}
