//
//  AdaptyProfileTests.swift
//  UnitTests
//
//  Created by Aleksei Valiano on 22.11.2022
//  Copyright © 2022 Adapty. All rights reserved.
//

@testable import AdaptySDK
import XCTest

func XCTAssertEqual(_ expression: AdaptyProfile?, withJSONValue jsonValue: JSONValue?, file: StaticString = #filePath, line: UInt = #line) {
    guard let (value, jsonValue) = XCTAssertNil(expression, withJSONValue: jsonValue, file: file, line: line) else { return }
    let object = jsonValue.objectOrFail(file: file, line: line)
    XCTAssertEqual(value.profileId, withJSONValue: object["profile_id"])
    XCTAssertEqual(value.customerUserId, withJSONValue: object["customer_user_id"])
//    XCTAssertEqual(value.codableCustomAttributes, withJSONValue: object["custom_attributes"])
}

final class AdaptyProfileTests: XCTestCase {
    func testDecodeValidJSON() throws {
        let all = try AdaptyProfile.ValidJSON.all.map {
            let result = try $0.jsonData().decode(AdaptyProfile.self)
            XCTAssertEqual(result, withJSONValue: $0)
            return result
        }
        XCTAssertFalse(all.isEmpty)
    }
}
