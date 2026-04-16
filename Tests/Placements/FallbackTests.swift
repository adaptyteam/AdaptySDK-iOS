//
//  FallbackTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 21.05.2025.
//

#if canImport(Testing)

@testable import Adapty
import AdaptyUIBuilder
import Foundation
import Testing

struct FallbackTests {
    enum Json: String {
        case medium = "fallback.json"
        var url: URL {
            Bundle.module.url(forResource: rawValue, withExtension: nil)!
        }
    }

    @Test func medium() throws {
        try test(json: Json.medium)
    }

    private struct Placement: Decodable {
        let isFlow: Bool
        let isOnboarding: Bool
        let viewConfigurationIds: [String]

        enum CodingKeys: String, CodingKey {
            case data
        }

        struct Variation: Decodable {
            let flowId: String?
            let onboardingId: String?
            let viewConfigurationId: String?

            enum CodingKeys: String, CodingKey {
                case flowId = "flow_id"
                case onboardingId = "onboarding_id"
                case viewConfigurationId = "flow_version_id"
            }
        }

        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            var item: Variation
            if let value = try? container.decode(Variation.self, forKey: .data) {
                item = value
                viewConfigurationIds = item.viewConfigurationId.map { [$0] } ?? []
            } else {
                let items = try container.decode([Variation].self, forKey: .data)
                item = try #require(items.first)
                viewConfigurationIds = items.compactMap(\.viewConfigurationId)
            }

            isFlow = item.flowId != nil
            isOnboarding = item.onboardingId != nil
        }
    }

    private func inspect(json: Json) throws -> (flows: [String], onboardings: [String], schemas: [String]) {
        let data = try Data(contentsOf: json.url).jsonExtract(pointer: "/data")
        let decoder = JSONDecoder()
        let result = try decoder.decode([String: Placement].self, from: data)

        var flows = [String]()
        var schemas = [String]()
        var onboardings = [String]()

        for item in result {
            if item.value.isFlow {
                flows.append(item.key)
                schemas.append(contentsOf: item.value.viewConfigurationIds)
            } else if item.value.isOnboarding {
                onboardings.append(item.key)
            } else {
                #expect(Bool(false), "Placement \(item.key) should contain either flow or onboarding")
            }
        }

        return (flows.sorted(), onboardings.sorted(), Array(Set(schemas)).sorted())
    }

    private func test(json: Json) throws {
        let (flows, onboardings, schemas) = try inspect(json: json)

        let startTime = CFAbsoluteTimeGetCurrent()
        let fallback = try FallbackPlacements(fileURL: json.url)
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("### Time elapsed for fallback: \(String(format: "%.6f", timeElapsed)) s.")

        print("### start testing onboardings")

        for placementId in onboardings {
            let startTime = CFAbsoluteTimeGetCurrent()
            do {
                let _: AdaptyPlacementChosen<AdaptyOnboarding>? = try fallback.getPlacement(
                    byPlacementId: placementId,
                    withVariationId: nil,
                    userId: .init(profileId: "test_profile", customerId: nil),
                    requestLocale: .init("en")
                )
            } catch {
                Issue.record("flow[\(placementId)]: \(error)")
            }
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            print("### Time elapsed for onboarding[\(placementId)]: \(String(format: "%.6f", timeElapsed)) s.")
        }

        print("### start testing flows")

        for placementId in flows {
            let startTime = CFAbsoluteTimeGetCurrent()
            do {
                let _: AdaptyPlacementChosen<AdaptyFlow>? = try fallback.getPlacement(
                    byPlacementId: placementId,
                    withVariationId: nil,
                    userId: .init(profileId: "test_profile", customerId: nil),
                    requestLocale: .init("en")
                )
            } catch {
                Issue.record("flow[\(placementId)]: \(error)")
            }
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime

            print("### Time elapsed for flow[\(placementId)]: \(String(format: "%.6f", timeElapsed)) s.")
        }

        print("### start testing schemas")

        for schemaId in schemas {
            let startTime = CFAbsoluteTimeGetCurrent()
            do {
                _ = try fallback.getUISchema(byViewConfigurationId: schemaId)
            } catch {
                Issue.record("schema[\(schemaId)]: \(error)")
            }
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            print("### schema[\(schemaId)]: \(String(format: "%.3f", timeElapsed))s")
        }
    }
}


#endif

