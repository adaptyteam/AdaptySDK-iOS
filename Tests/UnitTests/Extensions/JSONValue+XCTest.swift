//
//  JSONValue+XCTest.swift
//  UnitTests
//
//  Created by Aleksei Valiano on 22.11.2022
//  Copyright © 2022 Adapty. All rights reserved.
//

import Foundation
import XCTest

extension JSONValue {
    func stringOrFail(file: StaticString = #filePath, line: UInt = #line) -> String {
        guard let value = asStringOrNil else {
            XCTFail("Wrong JSONValue type \(self), expected string", file: file, line: line)
            fatalError()
        }
        return value
    }

    func intOrFail(file: StaticString = #filePath, line: UInt = #line) -> Int {
        guard let value = asIntOrNil else {
            XCTFail("Wrong JSONValue type \(self), expected int", file: file, line: line)
            fatalError()
        }
        return value
    }

    func floatOrFail(file: StaticString = #filePath, line: UInt = #line) -> Double {
        guard let value = asFloatOrNil else {
            XCTFail("Wrong JSONValue type \(self), expected float", file: file, line: line)
            fatalError()
        }
        return value
    }

    func boolOrFail(file: StaticString = #filePath, line: UInt = #line) -> Bool {
        guard let value = asBoolOrNil else {
            XCTFail("Wrong JSONValue type \(self), expected bool", file: file, line: line)
            fatalError()
        }
        return value
    }

    func arrayOrFail(file: StaticString = #filePath, line: UInt = #line) -> [JSONValue] {
        guard let value = asArrayOrNil else {
            XCTFail("Wrong JSONValue type \(self), expected array", file: file, line: line)
            fatalError()
        }
        return value
    }

    func objectOrFail(file: StaticString = #filePath, line: UInt = #line) -> [String: JSONValue] {
        guard let value = asObjectOrNil else {
            XCTFail("Wrong JSONValue type \(self), expected object", file: file, line: line)
            fatalError()
        }
        return value
    }
}

@discardableResult
func XCTAssertNil<T>(_ expression: T?, withJSONValue: JSONValue?, file: StaticString = #filePath, line: UInt = #line) -> (T, JSONValue)? {
    guard let jsonValue = withJSONValue, !jsonValue.isNull else {
        XCTAssertNil(expression, file: file, line: line)
        return nil
    }

    guard let value = expression else {
        XCTAssertNotNil(expression, file: file, line: line)
        return nil
    }

    return (value, jsonValue)
}

func XCTAssertEqual(_ expression: String?, withJSONValue jsonValue: JSONValue?, file: StaticString = #filePath, line: UInt = #line) {
    guard let (value, jsonValue) = XCTAssertNil(expression, withJSONValue: jsonValue, file: file, line: line) else { return }
    XCTAssertEqual(value, jsonValue.stringOrFail(file: file, line: line), file: file, line: line)
}

func XCTAssertEqual(_ expression: Int?, withJSONValue jsonValue: JSONValue?, file: StaticString = #filePath, line: UInt = #line) {
    guard let (value, jsonValue) = XCTAssertNil(expression, withJSONValue: jsonValue, file: file, line: line) else { return }
    XCTAssertEqual(value, jsonValue.intOrFail(file: file, line: line), file: file, line: line)
}

func XCTAssertEqual(_ expression: Double?, withJSONValue jsonValue: JSONValue?, file: StaticString = #filePath, line: UInt = #line) {
    guard let (value, jsonValue) = XCTAssertNil(expression, withJSONValue: jsonValue, file: file, line: line) else { return }
    XCTAssertEqual(value, jsonValue.floatOrFail(file: file, line: line), file: file, line: line)
}

func XCTAssertEqual(_ expression: Bool?, withJSONValue jsonValue: JSONValue?, file: StaticString = #filePath, line: UInt = #line) {
    guard let (value, jsonValue) = XCTAssertNil(expression, withJSONValue: jsonValue, file: file, line: line) else { return }
    XCTAssertEqual(value, jsonValue.boolOrFail(file: file, line: line), file: file, line: line)
}
