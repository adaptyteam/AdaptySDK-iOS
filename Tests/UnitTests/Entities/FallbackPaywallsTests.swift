//
//  FallbackPaywallsTests.swift
//  UnitTests
//
//  Created by Aleksei Valiano on 22.11.2022
//  Copyright © 2022 Adapty. All rights reserved.
//

@testable import AdaptySDK
import XCTest

func XCTAssertEqual(_ expression: FallbackPaywalls?, withJSONValue jsonValue: JSONValue?, file: StaticString = #filePath, line: UInt = #line) {
    func replaceEligibleToUnknown(_ object: [String: JSONValue]) -> [String: JSONValue] {
        var object = object
        if let introductoryOfferEligibility = object["introductory_offer_eligibility"] {
            switch introductoryOfferEligibility {
            case let .bool(value) where value:
                object["introductory_offer_eligibility"] = "unknown"
            case let .string(value) where value == "eligible":
                object["introductory_offer_eligibility"] = "unknown"
            default: break
            }
        }
        return object
    }

    guard let (value, jsonValue) = XCTAssertNil(expression, withJSONValue: jsonValue, file: file, line: line) else { return }
    let object = jsonValue.objectOrFail(file: file, line: line)
    let paywalls = object["data"]?.arrayOrFail()
    XCTAssertEqual(value.paywalls.count, paywalls?.count)
    paywalls?.forEach {
        var object = $0.objectOrFail()["attributes"]?.objectOrFail()
        XCTAssertNotNil(object)
        if let products = object!["products"]?.arrayOrFail() {
            object!["products"] = .array(products.map { .object(replaceEligibleToUnknown($0.objectOrFail())) })
        }
        let id = object!["developer_id"]?.stringOrFail()
        XCTAssertNotNil(id)
        XCTAssertEqual(value.paywalls[id!], withJSONValue: .object(object!))
    }

    let meta = object["meta"]?.objectOrFail()
    let products = meta?["products"]?.arrayOrFail()
    XCTAssertEqual(value.products.count, products?.count)
    products?.forEach {
        let object = replaceEligibleToUnknown($0.objectOrFail())
        let id = object["vendor_product_id"]?.stringOrFail()
        XCTAssertNotNil(id)
        XCTAssertEqual(value.products[id!], withJSONValue: .object(object))
    }
}

final class FallbackPaywallsTests: XCTestCase {
    func testDecodeValidJSON() throws {
        let all = try FallbackPaywalls.ValidJSON.all.map {
            let result = try $0.jsonData().decode(FallbackPaywalls.self)
            XCTAssertEqual(result, withJSONValue: $0)
            return result
        }
        XCTAssertFalse(all.isEmpty)
    }
}
