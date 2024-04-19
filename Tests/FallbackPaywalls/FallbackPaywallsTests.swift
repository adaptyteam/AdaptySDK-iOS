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
            let startTime = CFAbsoluteTimeGetCurrent()
            let data = try Data(contentsOf: self.url)
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            print("# Time elapsed for loadData: \(String(format: "%.6f", timeElapsed)) s.")
            return data
        }
    }

    static let paywallsIds = [
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

    func testFallback1() throws {
        let expectation = expectation(description: "wait setFallbackPaywalls")

        let data = try Json.fallbacks1.getData()

        let startTime = CFAbsoluteTimeGetCurrent()
        Adapty.setFallbackPaywalls(data) { _ in
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            print("## Time elapsed for setFallbackPaywalls: \(String(format: "%.6f", timeElapsed)) s.")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)

        let fallbackPaywalls = Adapty.Configuration.fallbackPaywalls!

        Self.paywallsIds.forEach {
            let startTime = CFAbsoluteTimeGetCurrent()
            let paywall = fallbackPaywalls.getPaywall(byPlacmentId: $0, profileId: "unknown")
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            print("### Time elapsed for paywall[\($0)] \(paywall?.value.viewConfiguration != nil ? "paywall_builder" : ""): \(String(format: "%.6f", timeElapsed)) s.")

            XCTAssertNotNil(paywall)
        }
    }

    func testFallback2() throws {
        let expectation = expectation(description: "wait setFallbackPaywalls")

        let data = try Json.fallbacks2.getData()

        let startTime = CFAbsoluteTimeGetCurrent()
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
            print("Time elapsed for paywall[\($0)] \(paywall?.value.viewConfiguration != nil ? "paywall_builder" : ""): \(String(format: "%.6f", timeElapsed)) s.")
            XCTAssertNotNil(paywall)
        }
    }
}
