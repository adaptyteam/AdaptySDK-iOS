//
//  BodyDecoder.swift
//
//
//  Created by Aleksei Valiano on 01.08.2024
//
//

import Foundation

enum BodyDecoder {
    private static func dictionary(from value: Any) throws -> [String: Any?] {
        guard let value = value as? [String: Any?] else {
            throw BodyDecoderError.isNotDictionary
        }

        return value
    }

    private static func array(from value: Any) throws -> [Any?] {
        guard let value = value as? [Any?] else {
            throw BodyDecoderError.isNotArray
        }

        return value
    }

    private static func string(from value: Any) throws -> String {
        guard let value = value as? String else {
            throw BodyDecoderError.isNotString
        }

        return value
    }

    private static func date(from value: Any) throws -> Date {
        guard let value = value as? Date else {
            throw BodyDecoderError.isNotDate
        }

        return value
    }

    private static func number(from value: Any) throws -> NSNumber {
        guard let value = value as? NSNumber else {
            throw BodyDecoderError.isNotNSNumber
        }

        return value
    }

    private static func bool(from value: Any) throws -> Bool {
        try number(from: value).boolValue
    }

    private static func int(from value: Any) throws -> Int {
        try number(from: value).intValue
    }

    private static func double(from value: Any) throws -> Double {
        try number(from: value).doubleValue
    }

    static func decode(_ value: Any?) -> Value {
        Value(value)
    }

    struct Dictionary {
        private let value: [String: Any?]

        fileprivate init(_ value: [String: Any?]) {
            self.value = value
        }

        subscript(_ key: String) -> Value {
            guard let value = value[key] else {
                return Value(nil)
            }
            return Value(value)
        }
    }

    struct Array {
        private let value: [Any?]

        fileprivate init(_ value: [Any?]) {
            self.value = value
        }

        func map<T>(transform: (Value) throws -> T) rethrows -> [T] {
            try value.map { try transform(Value($0)) }
        }
    }

    struct Value {
        private let value: Any?

        fileprivate init(_ value: Any?) {
            self.value = if value is NSNull {
                nil
            } else {
                value
            }
        }

        func asDictionary() throws -> Dictionary {
            guard let value else { throw BodyDecoderError.isNil }
            return try Dictionary(BodyDecoder.dictionary(from: value))
        }

        func asOptionalDictionary() throws -> Dictionary? {
            guard let value else { return nil }
            return try Dictionary(BodyDecoder.dictionary(from: value))
        }

        func asArray() throws -> Array {
            guard let value else { throw BodyDecoderError.isNil }
            return try Array(BodyDecoder.array(from: value))
        }

        func asOptionalArray() throws -> Array? {
            guard let value else { return nil }
            return try Array(BodyDecoder.array(from: value))
        }

        func asString() throws -> String {
            guard let value else { throw BodyDecoderError.isNil }
            return try BodyDecoder.string(from: value)
        }

        func asOptionalString() throws -> String? {
            guard let value else { return nil }
            return try BodyDecoder.string(from: value)
        }

        func asBool() throws -> Bool {
            guard let value else { throw BodyDecoderError.isNil }
            return try BodyDecoder.bool(from: value)
        }

        func asOptionalBool() throws -> Bool? {
            guard let value else { return nil }
            return try BodyDecoder.bool(from: value)
        }

        func asInt() throws -> Int {
            guard let value else { throw BodyDecoderError.isNil }
            return try BodyDecoder.int(from: value)
        }

        func asOptionalInt() throws -> Int? {
            guard let value else { return nil }
            return try BodyDecoder.int(from: value)
        }

        func asDouble() throws -> Double {
            guard let value else { throw BodyDecoderError.isNil }
            return try BodyDecoder.double(from: value)
        }

        func asOptionalDouble() throws -> Double? {
            guard let value else { return nil }
            return try BodyDecoder.double(from: value)
        }

        func asDate() throws -> Date {
            guard let value else { throw BodyDecoderError.isNil }
            return try BodyDecoder.date(from: value)
        }

        func asOptionalDate() throws -> Date? {
            guard let value else { return nil }
            return try BodyDecoder.date(from: value)
        }
    }
}
