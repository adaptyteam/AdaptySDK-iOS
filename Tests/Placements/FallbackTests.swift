//
//  FallbackTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 21.05.2025.
//

#if canImport(Testing)

@testable import Adapty
import Foundation
import Testing

struct FallbackTests {
    enum Json: String {
        case fallback = "fallback.json"
        var url: URL {
            Bundle.module.url(forResource: rawValue, withExtension: nil)!
        }
    }

    @Test func testFallbackPaywalls1() throws {
        try test(type: AdaptyPaywall.self, json: Json.fallback, placementIds: [
            "test_egor_placement_2",
        ])
    }

    @Test func testFallbackPaywalls() throws {
        try test(type: AdaptyPaywall.self, json: Json.fallback, placementIds: [
            "access.or.subscribe",
            "accesss",
            "all-onboarding",
            "anna-stage-ui-pm-a",
            "davyd_test_cdn",
            "example_ab_test",
            "fallbac-test-dbastrikin",
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
            "test_egor_placement_1",
            "test_egor_placement_2",
            "weekly-onboarding",
            "yealy-onboarding",
        ])
    }

    @Test func testFallbackOnboardings() throws {
        try test(type: AdaptyOnboarding.self, json: Json.fallback, placementIds: [
            "TestLera",
            "TestLera2",
            "evg",
            "evg2",
            "evg3",
            "mirazim-test",
        ])
    }

    func test<Content: AdaptyPlacementContent>(type: Content.Type, json: Json, placementIds: [String]) throws {
        let fallback = try FallbackPlacements(fileURL: json.url)

        for placementId in placementIds {
            let startTime = CFAbsoluteTimeGetCurrent()
            let content: AdaptyPlacementChosen<Content>? = fallback.getPlacement(byPlacementId: placementId, withVariationId: nil, profileId: "test_profile")
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime

            #expect(content != nil)

            print("### Time elapsed for placement[\(placementId)]: \(String(format: "%.6f", timeElapsed)) s.")
        }
    }
}
#endif
