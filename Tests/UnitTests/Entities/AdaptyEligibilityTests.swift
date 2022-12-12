//
//  AdaptyEligibilityTests.swift
//  UnitTests
//
//  Created by Aleksei Valiano on 22.11.2022
//  Copyright © 2022 Adapty. All rights reserved.
//

@testable import AdaptySDK
import XCTest

func XCTAssertEqual(_ value: AdaptyEligibility, withStringValue stringValue: String, file: StaticString = #filePath, line: UInt = #line) {
    switch stringValue {
    case "eligible": XCTAssertEqual(value, .eligible, file: file, line: line)
    case "ineligible": XCTAssertEqual(value, .ineligible, file: file, line: line)
    default: XCTAssertEqual(value, .unknown, file: file, line: line)
    }
}

func XCTAssertEqual(_ expression: AdaptyEligibility?, withJSONValue jsonValue: JSONValue?, file: StaticString = #filePath, line: UInt = #line) {
    guard let (value, jsonValue) = XCTAssertNil(expression, withJSONValue: jsonValue, file: file, line: line) else { return }
    XCTAssertEqual(value, withStringValue: jsonValue.stringOrFail(file: file, line: line), file: file, line: line)
}

final class AdaptyEligibilityTests: XCTestCase {
    func testDecodeValidJSON() throws {
        let all = try AdaptyEligibility.ValidJSON.all.map {
            let result = try $0.jsonData().decode(AdaptyEligibility.self)
            XCTAssertEqual(result, withJSONValue: $0)
            return result
        }
        XCTAssertFalse(all.isEmpty)
    }
}
