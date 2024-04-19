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

        func getData() throws -> Data {
            let startTime = CFAbsoluteTimeGetCurrent()
            let data = try Data(contentsOf: self.url)
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            print("# Time elapsed for loadData: \(String(format: "%.6f", timeElapsed)) s.")
            return data
        }

        func test(_ case: XCTestCase, paywallsId: String) throws {
            try test(`case`, paywallsIds: [paywallsId])
        }

        func test(_ case: XCTestCase, paywallsIds: [String]) throws {
            let expectation = `case`.expectation(description: "wait setFallbackPaywalls")

            let data = try getData()

            let startTime = CFAbsoluteTimeGetCurrent()
            Adapty.setFallbackPaywalls(data) { _ in
                let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
                print("## Time elapsed for setFallbackPaywalls: \(String(format: "%.6f", timeElapsed)) s.")

                expectation.fulfill()
            }

            `case`.wait(for: [expectation], timeout: 10.0)

            let fallbackPaywalls = Adapty.Configuration.fallbackPaywalls!

            paywallsIds.forEach {
                let startTime = CFAbsoluteTimeGetCurrent()
                let paywall = fallbackPaywalls.getPaywall(byPlacmentId: $0, profileId: "unknown")
                let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
                print("### Time elapsed for paywall[\($0)] \(paywall?.value.viewConfiguration != nil ? "paywall_builder" : ""): \(String(format: "%.6f", timeElapsed)) s.")

                XCTAssertNotNil(paywall)
            }
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

    func testFallback_serialized_inMemorry() throws {
        try Json.fallback_serialized.test(self, paywallsIds: paywallsIds)
    }

    func testFallback_inMemorry() throws {
        try Json.fallback.test(self, paywallsIds: paywallsIds)
    }

    func testFallback_serialized_reloadFile() throws {
        try paywallsIds.forEach { id in
            let startTime = CFAbsoluteTimeGetCurrent()
            try Json.fallback_serialized.test(self, paywallsId: id)
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            print("#### Total time elapsed for paywall[\(id)]: \(String(format: "%.6f", timeElapsed)) s.")
        }
    }

    func testFallback_reloadFile() throws {
        try paywallsIds.forEach { id in
            let startTime = CFAbsoluteTimeGetCurrent()
            try Json.fallback.test(self, paywallsId: id)
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            print("#### Total time elapsed for paywall[\(id)]: \(String(format: "%.6f", timeElapsed)) s.")
        }
    }
}
