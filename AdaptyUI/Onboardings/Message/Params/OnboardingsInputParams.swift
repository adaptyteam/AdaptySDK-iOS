//
//  OnboardingsInputParams.swift
//
//
//  Created by Aleksei Valiano on 09.08.2024
//
//

import Foundation

public enum OnboardingsInputParams: Sendable, Hashable {
    case text(String)
    case email(String)
    case number(Double)

    init(_ body: BodyDecoder.Value) throws {
        let body = try body.asDictionary()

        enum ValueType: String {
            case text
            case email
            case number
        }

        guard let valueType = try ValueType(rawValue: body["type"].asString()) else {
            throw BodyDecoderError.wrongValue
        }

        self =
            switch valueType {
            case .text:
                try .text(body["value"].asString())
            case .email:
                try .email(body["value"].asString())
            case .number:
                try .number(body["value"].asDouble())
            }
    }
}

extension OnboardingsInputParams: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .text(value):
            "{text: \(value)}"
        case let .email(value):
            "{email: \(value)}"
        case let .number(value):
            "{number: \(value)}"
        }
    }
}
