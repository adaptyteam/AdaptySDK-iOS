//
//  File.swift
//  Adapty
//
//  Created by Alexey Goncharov on 9/22/25.
//

import Foundation

public enum AdaptyUIBuilderError: Error {
    case unsupportedTemplate(String)
    case wrongComponentType(String)
}
