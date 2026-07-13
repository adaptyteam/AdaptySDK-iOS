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

    @Test func json_serialization_does_not_use_call_stack() throws {
        // 200_000 уровней. Даже при «тонком» кадре в 80 байт это ~16 МБ —
        // в дефолтный стек потока (512 КБ на background, 8 МБ на main) не лезет ни при каком раскладе.
        // Рекурсивный парсер упал бы по EXC_BAD_ACCESS до того, как успел бы что-то вернуть.
        let depth = 200_000
        var bytes = [UInt8]()
        bytes.reserveCapacity(depth * 2 + 1)
        bytes.append(contentsOf: repeatElement(UInt8(ascii: "["), count: depth))
        bytes.append(UInt8(ascii: "1"))
        bytes.append(contentsOf: repeatElement(UInt8(ascii: "]"), count: depth))
        let data = Data(bytes)

        // Итог: либо успех, либо чистый throws. Главное — мы дошли сюда живыми.
        var reachedTheCheck = false
        do {
            _ = try JSONSerialization.jsonObject(with: data)
            reachedTheCheck = true
        } catch {
            // NSError "JSON text did not start..." / depth limit — нас устраивает,
            // важно что это Error, а не SIGSEGV.
            reachedTheCheck = true
        }
        #expect(reachedTheCheck, "Если бы парсер был рекурсивным — мы бы сюда не добрались, тред умер бы.")
    }

    @Test func json_serialization_with_small_stack() throws {
        let depth = 400
        let json = String(repeating: "[", count: depth) + "1" + String(repeating: "]", count: depth)
        let data = Data(json.utf8)

        let sem = DispatchSemaphore(value: 0)
        nonisolated(unsafe) var ok = false
        nonisolated(unsafe) var err: Error?

        let t = Thread {
            defer { sem.signal() }
            do {
                _ = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
                ok = true
            } catch { err = error }
        }
        // 256 КБ — после вычета guard pages и базового overhead'а ещё остаётся
        // ~150–200 КБ полезного. Для 400 кадров рекурсии (≥80–200 КБ только под кадры)
        // это уже впритык/мало; для итеративного парсера — горы свободного места.
        t.stackSize = 256 * 1024
        t.start()
        sem.wait()

        if let err { throw err }
        #expect(ok)
    }

    @Test func read_all() throws {
        let data = try Data(contentsOf: Json.medium.url)//.jsonExtract(pointer: "/data")
        let startTime = CFAbsoluteTimeGetCurrent()

        let result = try JSONSerialization.jsonObject(with: data)
        #expect(result is [String:Any])
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("### Time elapsed for reading all: \(String(format: "%.6f", timeElapsed)) s.")

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

