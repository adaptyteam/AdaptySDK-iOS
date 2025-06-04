//
//  BodyDecoderError.swift
//
//
//  Created by Aleksei Valiano on 01.08.2024
//
//

import Foundation

enum BodyDecoderError: Error {
    case isNil
    case isNotDictionary
    case isNotArray
    case isNotNSNumber
    case isNotString
    case isNotDate
    case wrongValue
}
