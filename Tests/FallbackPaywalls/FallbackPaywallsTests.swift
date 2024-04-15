//
//  FallbackPaywallsTests.swift
//
//
//  Created by Aleksei Valiano on 09.02.2024
//
//
import XCTest
@testable import Adapty

final class FallbackPaywallsTests: XCTestCase {
    enum Json: String {
        case fallbacks1 = "fallbacks1.json"
        case fallbacks2 = "fallbacks2.json"

        var url: URL {
            let thisSourceFile = URL(fileURLWithPath: #file)
            let thisDirectory = thisSourceFile.deletingLastPathComponent()
            return thisDirectory.appendingPathComponent("\(self.rawValue)")
        }

        func getData() throws -> Data {
            try Data(contentsOf: self.url)
        }
    }

    static let paywallsIds = [
        "VGP23122801",
        "VGPM240212-2",
        "VGP240201",
        "VGP240214-1",
        "VGP240212-1",
        "VGP240131",
        "3",
        "gk-place-1",
        "example_ab_test",
        "test_placement_2",
        "sergey-placement",
        "test_alexey",
        "vlad1",
        "vlad",
        "ilia",
        "test_mykola",
        "volkswagen",
        "mazda",
        "anna-dev-ui-pm-b",
        "anna-dev-ui-pm",
        "new-placement",
        "migration_test",
        "test_kir",
    ]

    func testFallback1() throws {
        let expectation = expectation(description: "wait setFallbackPaywalls")

        let startTime = CFAbsoluteTimeGetCurrent()

        let data = try Json.fallbacks1.getData()


        Adapty.setFallbackPaywalls(data) { _ in

            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            print("Time elapsed for setFallbackPaywalls: \(String(format: "%.6f", timeElapsed)) s.")

            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)

        let fallbackPaywalls = Adapty.Configuration.fallbackPaywalls!

        Self.paywallsIds.forEach {
            let startTime = CFAbsoluteTimeGetCurrent()

            let paywall = fallbackPaywalls.getPaywall(byPlacmentId: $0, profileId: "unknown")

            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            print("Time elapsed for paywall[\($0)] \(paywall?.viewConfiguration != nil ? "paywall_builder" : ""): \(String(format: "%.6f", timeElapsed)) s.")

            XCTAssertNotNil(paywall)
        }
    }

    func testFallback2() throws {
        let expectation = expectation(description: "wait setFallbackPaywalls")

        let startTime = CFAbsoluteTimeGetCurrent()

        let data = try Json.fallbacks2.getData()



        Adapty.setFallbackPaywalls(data) { _ in

            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            print("Time elapsed for setFallbackPaywalls: \(String(format: "%.6f", timeElapsed)) s.")

            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)

        let fallbackPaywalls = Adapty.Configuration.fallbackPaywalls!

        Self.paywallsIds.forEach {
            let startTime = CFAbsoluteTimeGetCurrent()

            let paywall = fallbackPaywalls.getPaywall(byPlacmentId: $0, profileId: "unknown")

            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            print("Time elapsed for paywall[\($0)] \(paywall?.viewConfiguration != nil ? "paywall_builder" : ""): \(String(format: "%.6f", timeElapsed)) s.")
            XCTAssertNotNil(paywall)
        }
    }
}
