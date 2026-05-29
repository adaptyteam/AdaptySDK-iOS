//
//  File.swift
//  AdaptyUIBuilder
//
//  Created by Alexey Goncharov on 9/22/25.
//

import Foundation

public enum AdaptyUIBuilderError: Error {
    case wrongComponentType(String)
    case wrongAssetType(String)
    case jsException(String)
}
