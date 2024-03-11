//
//  AdaptyUIViewStyleTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 13.07.2023
//

@testable import Adapty
import XCTest

func XCTAssertEqual(_ expression: AdaptyUI.ViewConfiguration.ViewStyle?, withJSONValue jsonValue: JSONValue?, file: StaticString = #filePath, line: UInt = #line) {
    guard let (value, jsonValue) = XCTAssertNil(expression, withJSONValue: jsonValue, file: file, line: line) else { return }
    let object = jsonValue.objectOrFail(file: file, line: line)
    print(value)
    print(object)
}

final class AdaptyUIViewStyleTests: XCTestCase {
    func testDecodeValidJSON() throws {
        let all = try AdaptyUI.ViewConfiguration.ViewStyle.ValidJSON.all.map {
            let result = try $0.jsonData().decode(AdaptyUI.ViewConfiguration.ViewStyle.self)
            XCTAssertEqual(result, withJSONValue: $0)
            return result
        }
        XCTAssertFalse(all.isEmpty)
    }

    func testDecodeInvalidJSON() throws {
        let all = AdaptyUI.ViewConfiguration.ViewStyle.InvalidJSON.all
        XCTAssertFalse(all.isEmpty)
        try all.forEach {
            let data = try $0.jsonData()
            do {
                _ = try data.decode(AdaptyUI.ViewConfiguration.ViewStyle.self)
                XCTFail("Must be decoding error for \($0)")
            } catch { }
        }
    }
}
