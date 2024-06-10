//
//  AdaptyUIComparingversionTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 19.01.2023
//

import XCTest
@testable import Adapty

final class AdaptyUIComparingversionTests: XCTestCase {
    func testValid() throws {
        let pairs = [
            ("2.0.0", "2"),
            ("2.0.0", "2.0"),
            ("2.0.0", "2.0.0"),
            ("2.0.0", "2.0.0.0"),
            ("2.0.0", "2.0.0-SNAPSHOT"),
            ("2.0.0-SNAPSHOT", "2.0.0-RC1"),
            ("2.0.1", "2.0.0"),
            ("3", "2.0.0"),
            ("3.1.0", "3.0.9999"),
        ]

        XCTAssertFalse(pairs.isEmpty)
        pairs.forEach { newer, older in
            XCTAssertTrue(newer.isSameOrNewerVersion(than: older), "version \(newer) is not same or newer than \(older)")
        }
    }

    func testInvalid() throws {
        let pairs = [
            ("2.0.0", "3"),
            ("2.0.0", "3.0"),
            ("2.0.0", "2.0.1"),
            ("2.0.0", "2.0.0.1"),
            ("2.0-SNAPSHOT", "2.0.0.1"),
            ("2.0.1", "2.1.0"),
            ("SNAPSHOT", "0.0.1"),
        ]

        XCTAssertFalse(pairs.isEmpty)
        pairs.forEach { newer, older in
            XCTAssertFalse(newer.isSameOrNewerVersion(than: older), "version \(newer) is not older than \(older)")
        }
    }
}
