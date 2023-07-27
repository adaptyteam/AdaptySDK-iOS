//
//  AdaptyUIAssetTests.swift
//  UnitTests
//
//  Created by Aleksei Valiano on 19.01.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

@testable import AdaptySDK
import XCTest

func XCTAssertEqual(_ expression: AdaptyUI.Color?, withJSONValue jsonValue: JSONValue?, file: StaticString = #filePath, line: UInt = #line) {
    guard let (value, jsonValue) = XCTAssertNil(expression, withJSONValue: jsonValue, file: file, line: line) else { return }
    var str = jsonValue.stringOrFail(file: file, line: line)
    if str.count == 7 { str += "ff" }
    let hex = value.asHexString
    XCTAssertEqual(hex.lowercased(), str.lowercased())
}

func XCTAssertEqual(_ expression: [String: AdaptyUI.Asset]?, withJSONValue jsonValue: JSONValue?, file: StaticString = #filePath, line: UInt = #line) {
    guard let (assets, jsonValue) = XCTAssertNil(expression, withJSONValue: jsonValue, file: file, line: line) else { return }
    let array = jsonValue.arrayOrFail(file: file, line: line)

    XCTAssertEqual(assets.count, array.count)
    for jsonValue in array {
        let object = jsonValue.objectOrFail(file: file, line: line)

        guard let id = object["id"]?.asStringOrNil else {
            XCTFail("Json object required `id` field")
            return
        }
        guard let type = object["type"]?.asStringOrNil else {
            XCTFail("Json object required `type` field")
            return
        }

        guard let value = assets[id] else {
            XCTFail("Missing asset by id = \(id)")
            return
        }

        switch value {
        case let .filling(.image(value)):
            XCTAssertEqual("image", type)
            XCTAssertEqual(value.data, withJSONValue: object["value"])
        case let .filling(.color(value)):
            XCTAssertEqual("color", type)
            XCTAssertEqual(value, withJSONValue: object["value"])
        case .filling(.colorGradient):
            XCTAssertEqual("linear-gradient", type)
        // TODO: implement check
        case let .font(value):
            XCTAssertEqual("font", type)
            XCTAssertEqual(value.name, withJSONValue: object["value"])
            XCTAssertEqual(value.style, withJSONValue: object["style"])
            XCTAssertEqual(value.defaultSize, withJSONValue: object["size"])
            XCTAssertEqual(value.defaultColor, withJSONValue: object["color"])
        case let .unknown(value):
            XCTFail("Unknown asset with type = \(value == nil ? "nil" : value!)")
            return
        }
    }
}

final class AdaptyUIAssetTests: XCTestCase {
    func testDecodeValidJSON() throws {
        let all = try AdaptyUI.Assets.ValidJSON.all.map {
            let result = try $0.jsonData().decode(AdaptyUI.Assets.self)
            XCTAssertEqual(result.value, withJSONValue: $0)
            return result
        }
        XCTAssertFalse(all.isEmpty)
    }

    func testDecodeInvalidJSON() throws {
        let all = AdaptyUI.Assets.InvalidJSON.all
        XCTAssertFalse(all.isEmpty)
        try all.forEach {
            let data = try $0.jsonData()
            do {
                _ = try data.decode(AdaptyUI.Assets.self)
                XCTFail("Must be decoding error for \($0)")
            } catch { }
        }
    }
}
