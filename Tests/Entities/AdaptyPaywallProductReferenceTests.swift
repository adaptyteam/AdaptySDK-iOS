//
//  AdaptyPaywallProductReferenceTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 16.05.2023
//

@testable import Adapty
import XCTest

func XCTAssertEqual(_ expression: AdaptyPaywall.ProductReference?, withJSONValue jsonValue: JSONValue?, file: StaticString = #filePath, line: UInt = #line) {
    guard let (value, jsonValue) = XCTAssertNil(expression, withJSONValue: jsonValue, file: file, line: line) else { return }
    let object = jsonValue.objectOrFail(file: file, line: line)
    XCTAssertEqual(value.vendorId, withJSONValue: object["vendor_product_id"])
    if value.promotionalOfferEligibility {
        XCTAssertEqual(value.promotionalOfferId, withJSONValue: object["promotional_offer_id"])
    }
}

final class AdaptyPaywallProductReferenceTests: XCTestCase {
    func testDecodeValidJSON() throws {
        let all = try AdaptyPaywall.ProductReference.ValidJSON.all.map {
            let result = try $0.jsonData().decode(AdaptyPaywall.ProductReference.self)
            XCTAssertEqual(result, withJSONValue: $0)
            return result
        }
        XCTAssertFalse(all.isEmpty)
        XCTAssertNotNil(all.first(where: { $0.promotionalOfferId != nil }))
    }

    func testDecodeInvalidJSON() throws {
        let all = AdaptyPaywall.ProductReference.InvalidJSON.all
        XCTAssertFalse(all.isEmpty)
        try all.forEach {
            let data = try $0.jsonData()
            do {
                _ = try data.decode(AdaptyPaywall.ProductReference.self)
                XCTFail("Must be decoding error for \($0)")
            } catch { }
        }
    }
}
