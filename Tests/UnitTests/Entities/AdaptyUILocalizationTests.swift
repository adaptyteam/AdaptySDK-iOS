//
//  AdaptyUILocalizationTests.swift
//  UnitTests
//
//  Created by Aleksei Valiano on 19.01.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

@testable import AdaptySDK
import XCTest

func XCTAssertEqual(_ expression: AdaptyLocale?, withJSONValue jsonValue: JSONValue?, file: StaticString = #filePath, line: UInt = #line) {
    guard let (value, jsonValue) = XCTAssertNil(expression, withJSONValue: jsonValue, file: file, line: line) else { return }
    XCTAssertEqual(value.id, jsonValue.stringOrFail(file: file, line: line), file: file, line: line)
}

func XCTAssertEqual(_ expression: AdaptyUI.Localization?, withJSONValue jsonValue: JSONValue?, file: StaticString = #filePath, line: UInt = #line) {
    guard let (value, jsonValue) = XCTAssertNil(expression, withJSONValue: jsonValue, file: file, line: line) else { return }
    let object = jsonValue.objectOrFail(file: file, line: line)

    XCTAssertEqual(value.id, withJSONValue: object["id"])
    XCTAssertEqual(value.assets, withJSONValue: object["assets"])

    let strings = object["strings"]!.arrayOrFail(file: file, line: line)

    XCTAssertEqual(value.strings?.count ?? 0, strings.count)
    for jsonValue in strings {
        let object = jsonValue.objectOrFail(file: file, line: line)

        guard let id = object["id"]?.asStringOrNil else {
            XCTFail("Json object required `id` field")
            return
        }

        XCTAssertEqual(value.strings![id], withJSONValue: object["value"])
    }
}

final class AdaptyUILocalizationTests: XCTestCase {
    func testDecodeValidJSON() throws {
        let all = try AdaptyUI.Localization.ValidJSON.all.map {
            let result = try $0.jsonData().decode(AdaptyUI.Localization.self)
            XCTAssertEqual(result, withJSONValue: $0)
            return result
        }
        XCTAssertFalse(all.isEmpty)
    }

    func testDecodeInvalidJSON() throws {
        let all = AdaptyUI.Localization.InvalidJSON.all
        XCTAssertFalse(all.isEmpty)
        try all.forEach {
            let data = try $0.jsonData()
            do {
                _ = try data.decode(AdaptyUI.Localization.self)
                XCTFail("Must be decoding error for \($0)")
            } catch { }
        }
    }
}
