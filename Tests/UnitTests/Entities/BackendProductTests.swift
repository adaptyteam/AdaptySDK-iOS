//
//  BackendProductTests.swift
//  UnitTests
//
//  Created by Aleksei Valiano on 22.11.2022
//  Copyright © 2022 Adapty. All rights reserved.
//

@testable import AdaptySDK
import XCTest

func XCTAssertEqual(_ expression: BackendProduct?, withJSONValue jsonValue: JSONValue?, file: StaticString = #filePath, line: UInt = #line) {
    guard let (value, jsonValue) = XCTAssertNil(expression, withJSONValue: jsonValue, file: file, line: line) else { return }
    let object = jsonValue.objectOrFail(file: file, line: line)
    XCTAssertEqual(value.vendorId, withJSONValue: object["vendor_product_id"])
    XCTAssertEqual(value.promotionalOfferId, withJSONValue: object["promotional_offer_id"])
    XCTAssertEqual(value.promotionalOfferEligibility, withJSONValue: object["promotional_offer_eligibility"])
    if let boolValue = object["introductory_offer_eligibility"]?.asBoolOrNil {
        XCTAssertEqual(value.introductoryOfferEligibility, AdaptyEligibility(booleanLiteral: boolValue))
    } else {
        XCTAssertEqual(value.introductoryOfferEligibility, withJSONValue: object["introductory_offer_eligibility"])
    }
    XCTAssertEqual(Int(value.version), withJSONValue: object["timestamp"])
}

final class BackendProductTests: XCTestCase {
    func testDecodeValidJSON() throws {
        let all = try BackendProduct.ValidJSON.all.map {
            let result = try $0.jsonData().decode(BackendProduct.self)
            XCTAssertEqual(result, withJSONValue: $0)
            return result
        }
        XCTAssertFalse(all.isEmpty)
        XCTAssertNotNil(all.first(where: { $0.promotionalOfferId != nil }))
    }

    func testDecodeInvalidJSON() throws {
        let all = BackendProduct.InvalidJSON.all
        XCTAssertFalse(all.isEmpty)
        try all.forEach {
            let data = try $0.jsonData()
            do {
                _ = try data.decode(BackendProduct.self)
                XCTFail("Must be decoding error for \($0)")
            } catch { }
        }
    }
}
