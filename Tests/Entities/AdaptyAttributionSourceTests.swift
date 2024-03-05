//
//  AdaptyAttributionSourceTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 22.11.2022
//

@testable import Adapty
import XCTest

func XCTAssertEqual(_ value: AdaptyAttributionSource, withStringValue stringValue: String, file: StaticString = #filePath, line: UInt = #line) {
    switch stringValue {
    case "adjust": XCTAssertEqual(value, .adjust, file: file, line: line)
    case "appsflyer": XCTAssertEqual(value, .appsflyer, file: file, line: line)
    case "branch": XCTAssertEqual(value, .branch, file: file, line: line)
    case "custom": XCTAssertEqual(value, .custom, file: file, line: line)
    default: XCTFail("unknown value \"\(stringValue)\"", file: file, line: line)
    }
}

func XCTAssertEqual(_ expression: AdaptyAttributionSource?, withJSONValue jsonValue: JSONValue?, file: StaticString = #filePath, line: UInt = #line) {
    guard let (value, jsonValue) = XCTAssertNil(expression, withJSONValue: jsonValue, file: file, line: line) else { return }
    XCTAssertEqual(value, withStringValue: jsonValue.stringOrFail(file: file, line: line), file: file, line: line)
}

final class AdaptyAttributionSourceTests: XCTestCase {
    func testDecodeValidJSON() throws {
        let all = try AdaptyAttributionSource.ValidJSON.all.map {
            let result = try $0.jsonData().decode(AdaptyAttributionSource.self)
            XCTAssertEqual(result, withJSONValue: $0)
            return result
        }
        XCTAssertFalse(all.isEmpty)
    }

    func testDecodeInvalidJSON() throws {
        let all = AdaptyAttributionSource.InvalidJSON.all
        XCTAssertFalse(all.isEmpty)
        try all.forEach {
            let data = try $0.jsonData()
            do {
                _ = try data.decode(AdaptyAttributionSource.self)
                XCTFail("Must be decoding error for \($0)")
            } catch { }
        }
    }
}
