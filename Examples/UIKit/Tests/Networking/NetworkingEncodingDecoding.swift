//
//  NetworkingEncodingDecoding.swift
//  Adapty_Tests
//
//  Created by Aleksey Goncharov on 10.10.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

@testable import Adapty
import XCTest

final class NetworkingEncodingDecoding: XCTestCase {
    func testDateFormatter() throws {
        let jsonString = "[\"2022-10-10T16:57:13.123+0\",\"2022-10-10T16:57:13.123Z\",\"2022-10-10T16:57:13.000Z\"]"

        guard let jsonData = jsonString.data(using: .utf8) else {
            XCTAssertFalse(true)
            return
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Backend.dateFormatter)

        do {
            let result = try decoder.decode([Date].self, from: jsonData)
            
            for date in result {
                let comps = Calendar.current.dateComponents(in: TimeZone(identifier: "UTC")!, from: date)
                
                XCTAssertEqual(comps.year, 2022)
                XCTAssertEqual(comps.month, 10)
                XCTAssertEqual(comps.day, 10)
                
                XCTAssertEqual(comps.hour, 16)
                XCTAssertEqual(comps.minute, 57)
                XCTAssertEqual(comps.second, 13)
            }
        } catch {
            XCTAssertFalse(true)
        }
    }
}
