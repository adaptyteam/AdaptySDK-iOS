//
//  FallbackPaywallsTest.swift
//  Adapty_Tests
//
//  Created by Aleksey Goncharov on 19.10.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

@testable import Adapty
import XCTest

final class Models_Fallback: XCTestCase {
    func test_Create() throws {
        let data = try Tester.jsonDataNamed("fallback_example")
        let result = try FallbackPaywalls(from: data)

        XCTAssertEqual(result.allProductVendorIds.count, 5)
        XCTAssertEqual(result.paywalls.count, 4)
    }
}
