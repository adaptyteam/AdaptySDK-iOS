//
//  AdaptyUIViewConfigurationTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 19.09.2023
//

@testable import Adapty
import XCTest

func XCTAssertEqual(_ expression: AdaptyUI.ViewConfiguration?, withJSONValue jsonValue: JSONValue?, file: StaticString = #filePath, line: UInt = #line) {
    guard let (value, jsonValue) = XCTAssertNil(expression, withJSONValue: jsonValue, file: file, line: line) else { return }
    let object = jsonValue.objectOrFail(file: file, line: line)
    print(value)
    print(object)
}

final class AdaptyUIViewConfigurationTests: XCTestCase {
    func testDecodeValidJSON() throws {
        let all = try AdaptyUI.ViewConfiguration.ValidJSON.all.map {
            let result = try $0.jsonData().decode(AdaptyUI.ViewConfiguration.self)
            XCTAssertEqual(result, withJSONValue: $0)
            return result
        }
        XCTAssertFalse(all.isEmpty)
    }

    func testDecodeInvalidJSON() throws {
        let all = AdaptyUI.ViewConfiguration.InvalidJSON.all
        XCTAssertFalse(all.isEmpty)
        try all.forEach {
            let data = try $0.jsonData()
            do {
                _ = try data.decode(AdaptyUI.ViewConfiguration.self)
                XCTFail("Must be decoding error for \($0)")
            } catch { }
        }
    }
}
