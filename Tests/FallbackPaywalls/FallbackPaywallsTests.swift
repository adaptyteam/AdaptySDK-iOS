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
        case fallback_serialized = "fallbacks1.json"
        case fallback = "fallbacks2.json"

        var url: URL {
            let thisSourceFile = URL(fileURLWithPath: #file)
            let thisDirectory = thisSourceFile.deletingLastPathComponent()
            return thisDirectory.appendingPathComponent("\(self.rawValue)")
        }
    }

    let paywallsIds = [
        "access.or.subscribe",
        "accesss",
        "all-onboarding",
        "anna-stage-ui-pm-a",
        "davyd_test_cdn",
        "example_ab_test",
        "fonts_migration",
        "meets.or.access",
        "meets.subscrubes",
        "mopnthly-onboarding",
        "new_placement",
        "oboarding.access",
        "onboarding",
        "onboarding-multiply",
        "onboarding-workout",
        "promo",
        "settings",
        "test_alexey",
        "weekly-onboarding",
        "yealy-onboarding",
    ]

    func test(fileURL url: URL, paywallsId: String) throws {
        try test(fileURL: url, paywallsIds: [paywallsId])
    }

    func test(fileURL url: URL, paywallsIds: [String]) throws {
        let expectation = expectation(description: "wait setFallbackPaywalls")

        let startTime = CFAbsoluteTimeGetCurrent()
        Adapty.setFallbackPaywalls(fileURL: url) { _ in
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            print("## Time elapsed for setFallbackPaywalls: \(String(format: "%.6f", timeElapsed)) s.")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)

        let fallbackPaywalls = Adapty.Configuration.fallbackPaywalls!

        paywallsIds.forEach {
            let startTime = CFAbsoluteTimeGetCurrent()
            let paywall = fallbackPaywalls.getPaywall(byPlacmentId: $0, profileId: "unknown")
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            print("### Time elapsed for paywall[\($0)] \(paywall?.value.viewConfiguration != nil ? "paywall_builder" : ""): \(String(format: "%.6f", timeElapsed)) s.")

            XCTAssertNotNil(paywall)
        }
    }

    func testFallback_serialized() throws {
        try test(fileURL: Json.fallback_serialized.url, paywallsIds: paywallsIds)
    }

    func testFallback() throws {
        try test(fileURL: Json.fallback.url, paywallsIds: paywallsIds)
    }
}
