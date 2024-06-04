//
//  AdaptyUIDateStringTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 19.01.2023
//

import XCTest
@testable import Adapty

final class AdaptyUIDateStringTests: XCTestCase {
    func stringToDateString(_ value: String) throws -> AdaptyUI.ViewConfiguration.DateString {
        struct JSON: Decodable {
            let v: AdaptyUI.ViewConfiguration.DateString
        }
        let json = try JSONDecoder().decode(JSON.self, from: "{\"v\":\"\(value)\"}".data(using: .utf8)!)
        return json.v
    }

    func utcDateToString(_ value: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: value)
    }

    func localDateToString(_ value: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: value)
    }

    func testValidUTC() throws {
        let all = [
            "2024-06-04 12:00:00",
            "2024-06-04 23:59:59",
            "2024-06-04 00:00:00",
            "2024-02-04 12:00:00",
            "2024-02-04 23:59:59",
            "2024-02-04 00:00:00",
        ]

        XCTAssertFalse(all.isEmpty)
        try all.forEach {
            let value = try stringToDateString($0)
            let utc = utcDateToString(value.utc)
            let local = localDateToString(value.local)

            XCTAssertEqual(utcDateToString(value.utc), $0)
            XCTAssertEqual(localDateToString(value.local), $0)

            XCTAssertNotEqual(localDateToString(value.utc), $0)
            XCTAssertNotEqual(utcDateToString(value.local), $0)
        }
    }

    func testWrongFormat() throws {
        let all = [
            "data",
            "12:00:00",
            "2024-06-04 12:00",
            "2024-56-04 12:00:00",
            "2024-02-00 12:00:00",
            
        ]

        XCTAssertFalse(all.isEmpty)
        try all.forEach {
            do {
                _ = try stringToDateString($0)
                XCTFail("Must be decoding error for \($0)")
            } catch {}
        }
    }
}
