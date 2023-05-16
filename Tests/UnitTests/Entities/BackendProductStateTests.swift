//
//  BackendProductStateTests.swift
//  UnitTests
//
//  Created by Aleksei Valiano on 22.11.2022
//  Copyright © 2022 Adapty. All rights reserved.
//

@testable import AdaptySDK
import XCTest

func XCTAssertEqual(_ expression: BackendProductState?, withJSONValue jsonValue: JSONValue?, file: StaticString = #filePath, line: UInt = #line) {
    guard let (value, jsonValue) = XCTAssertNil(expression, withJSONValue: jsonValue, file: file, line: line) else { return }
    let object = jsonValue.objectOrFail(file: file, line: line)
    XCTAssertEqual(value.vendorId, withJSONValue: object["vendor_product_id"])
    if let boolValue = object["introductory_offer_eligibility"]?.asBoolOrNil {
        if boolValue {
            XCTAssertEqual(value.introductoryOfferEligibility, .eligible)
        } else {
            XCTAssertEqual(value.introductoryOfferEligibility, .ineligible)
        }
    } else {
        XCTAssertEqual(value.introductoryOfferEligibility, withJSONValue: object["introductory_offer_eligibility"])
    }
    XCTAssertEqual(Int(value.version), withJSONValue: object["timestamp"])
}

final class BackendProductStateTests: XCTestCase {
    func testDecodeValidJSON() throws {
        let all = try BackendProductState.ValidJSON.all.map {
            let result = try $0.jsonData().decode(BackendProductState.self)
            XCTAssertEqual(result, withJSONValue: $0)
            return result
        }
        XCTAssertFalse(all.isEmpty)
    }

    func testDecodeInvalidJSON() throws {
        let all = BackendProductState.InvalidJSON.all
        XCTAssertFalse(all.isEmpty)
        try all.forEach {
            let data = try $0.jsonData()
            do {
                _ = try data.decode(BackendProductState.self)
                XCTFail("Must be decoding error for \($0)")
            } catch { }
        }
    }
}
