//
//  FallbackPaywallsTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 22.11.2022
//

@testable import Adapty
import XCTest

func XCTAssertEqual(_ expression: FallbackPaywalls?, withJSONValue jsonValue: JSONValue?, file: StaticString = #filePath, line: UInt = #line) {

    guard let (value, jsonValue) = XCTAssertNil(expression, withJSONValue: jsonValue, file: file, line: line) else { return }
    let object = jsonValue.objectOrFail(file: file, line: line)
    let paywalls = object["data"]?.arrayOrFail()
    XCTAssertEqual(value.paywallByPlacementId.count, paywalls?.count)
    paywalls?.forEach {
        var object = $0.objectOrFail()["attributes"]?.objectOrFail()
        XCTAssertNotNil(object)
        if let products = object!["products"]?.arrayOrFail() {
            object!["products"] = .array(products.map { .object($0.objectOrFail()) })
        }
        let placementId = object!["developer_id"]?.stringOrFail()
        XCTAssertNotNil(placementId)
        XCTAssertEqual(value.paywallByPlacementId[placementId!], withJSONValue: .object(object!))
    }

    let meta = object["meta"]?.objectOrFail()
    XCTAssertEqual(value.version, withJSONValue: meta?["version"])
    let products = meta?["products"]?.arrayOrFail()
    XCTAssertEqual(value.allProductVendorIds.count, products?.count)
    products?.forEach {
        let object = $0.objectOrFail()
        let id = object["vendor_product_id"]?.stringOrFail()
        XCTAssertNotNil(id)
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
