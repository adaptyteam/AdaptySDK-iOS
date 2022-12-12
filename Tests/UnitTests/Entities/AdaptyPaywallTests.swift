//
//  AdaptyPaywallTests.swift
//  UnitTests
//
//  Created by Aleksei Valiano on 22.11.2022
//  Copyright © 2022 Adapty. All rights reserved.
//

@testable import AdaptySDK
import XCTest

func XCTAssertEqual(_ expression: AdaptyPaywall?, withJSONValue jsonValue: JSONValue?, file: StaticString = #filePath, line: UInt = #line) {
    guard let (value, jsonValue) = XCTAssertNil(expression, withJSONValue: jsonValue, file: file, line: line) else { return }
    let object = jsonValue.objectOrFail(file: file, line: line)
    XCTAssertEqual(value.id, withJSONValue: object["developer_id"])
    XCTAssertEqual(value.revision, withJSONValue: object["revision"])
    XCTAssertEqual(value.variationId, withJSONValue: object["variation_id"])
    XCTAssertEqual(value.abTestName, withJSONValue: object["ab_test_name"])
    XCTAssertEqual(value.name, withJSONValue: object["paywall_name"])
    XCTAssertEqual(value.remoteConfigString, withJSONValue: object["custom_payload"])
    XCTAssertEqual(Int(value.version), withJSONValue: object["paywall_updated_at"])
    let products = object["products"]?.arrayOrFail(file: file, line: line)
    XCTAssertEqual(value.products.count, products?.count)
    for i in 0 ..< value.products.count {
        XCTAssertEqual(value.products[i], withJSONValue: products?[i])
    }
}

final class AdaptyPaywallTests: XCTestCase {
    func testDecodeValidJSON() throws {
        let all = try AdaptyPaywall.ValidJSON.all.map {
            let result = try $0.jsonData().decode(AdaptyPaywall.self)
            XCTAssertEqual(result, withJSONValue: $0)
            return result
        }
        XCTAssertFalse(all.isEmpty)
        XCTAssertNotNil(all.first(where: { $0.remoteConfigString != nil }))
    }

    func testDecodeInvalidJSON() throws {
        let all = AdaptyPaywall.InvalidJSON.all
        XCTAssertFalse(all.isEmpty)
        try all.forEach {
            let data = try $0.jsonData()
            do {
                _ = try data.decode(AdaptyPaywall.self)
                XCTFail("Must be decoding error for \($0)")
            } catch { }
        }
    }
}
