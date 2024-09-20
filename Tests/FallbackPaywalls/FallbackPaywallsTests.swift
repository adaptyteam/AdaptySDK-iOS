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
        case fallback = "fallbacks.json"

        var url: URL {
            let thisSourceFile = URL(fileURLWithPath: #file)
            let thisDirectory = thisSourceFile.deletingLastPathComponent()
            return thisDirectory.appendingPathComponent("\(self.rawValue)")
        }
    }

    let paywallsIds = [
        "test_sergey",
        "mazda",
        "VGPM240212-2",
        "test_anna_bani",
        "sergey-placement",
        "VGP240212-1",
        "test_alexey",
        "evgeniy28",
        "example_ab_test",
        "vlad",
        "ilia",
        "test_mykola",
        "VGP240214-1",
        "test_kir",
        "gk-place-1",
        "test_anton_2",
        "test_anna",
        "vitaly-test-builder",
        "x2",
        "volkswagen",
        "new-placement",
        "test_anna_gani",
        "test_anton",
        "VGP23122801",
        "x3",
        "VGP240201",
        "VGP240131",
        "migration_test",
        "vlad1",
        "3",
    ]

    func test(fileURL url: URL, paywallsId: String) throws {
        try test(fileURL: url, paywallsIds: [paywallsId])
    }

    func test(fileURL url: URL, paywallsIds: [String]) throws {
        let expectation = expectation(description: "wait setFallbackPaywalls")

        let startTime = CFAbsoluteTimeGetCurrent()
        Adapty.setFallbackPaywalls(fileURL: url) { error in

            XCTAssertNil(error)

            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            print("## Time elapsed for setFallbackPaywalls: \(String(format: "%.6f", timeElapsed)) s.")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)

        let fallbackPaywalls = Adapty.Configuration.fallbackPaywalls!

        paywallsIds.forEach {
            let startTime = CFAbsoluteTimeGetCurrent()
            let paywall = fallbackPaywalls.getPaywall(byPlacementId: $0, profileId: "unknown")
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            print("### Time elapsed for paywall[\($0)] \(paywall?.value.viewConfiguration != nil ? "paywall_builder" : ""): \(String(format: "%.6f", timeElapsed)) s.")

            XCTAssertNotNil(paywall)
        }
    }

    func testFallback() throws {
        try test(fileURL: Json.fallback.url, paywallsIds: paywallsIds)
    }
}
