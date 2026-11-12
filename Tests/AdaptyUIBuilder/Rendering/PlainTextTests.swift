//
//  PlainTextTests.swift
//  AdaptyTests
//

#if canImport(UIKit)

@testable import AdaptyUIBuilder
import Foundation
import Testing

/// Alert dialogs and URLs take a string id as plain text: the whole string,
/// tags substituted, attributes dropped.
@Suite(
    "AdaptyUIBuilder Tests",
    .component("AdaptyUIBuilder"),
    .epic("Alert Dialog"),
    .feature("Plain Text"),
    .risk(.critical),
    .owner("Aleksey Goncharov"),
    .layer(.unit),
    .tags(.logic)
)
@MainActor
struct PlainTextTests {
    @Test("Takes the whole string past a tag and drops the attributes")
    func wholeStringWithTag() throws {
        #expect(try Self.plainText("greeting") == "Hi, Ann!")
    }

    @Test("A tag that does not resolve takes the localization fallback")
    func unresolvedTagTakesFallback() throws {
        #expect(try Self.plainText("price") == "See the offer")
    }

    @Test("A string id that is not localized gives nothing")
    func notLocalized() throws {
        #expect(try Self.plainText("missing") == nil)
    }

    private struct NameResolver: AdaptyUITagResolver {
        func replacement(for tag: String) -> String? { tag == "NAME" ? "Ann" : nil }
    }

    private static func plainText(_ stringId: String) throws -> String? {
        let flow = try AdaptyUIBuilder.FlowConfiguration(
            logId: "plain-text-test",
            viewConfiguration: configuration(),
            products: [],
            tagResolver: NameResolver(),
            timerResolver: nil,
            assetsResolver: nil
        )
        return flow.assetsViewModel.plainText(
            stringId,
            screen: AdaptyUIScreenInstanceKey.defaultValue,
            stateViewModel: flow.stateViewModel,
            customTagResolver: flow.tagResolverViewModel,
            showsDebugPlaceholders: false
        )
    }

    private static func configuration() throws -> AdaptyUIConfiguration {
        let schema = try AdaptyUISchema(
            from: """
            {
              "format": "5.2.0",
              "screens": { "main": { "content": { "type": "text", "string_id": "greeting" } } },
              "localizations": [{
                "id": "en",
                "strings": [
                  { "id": "greeting", "value": ["Hi, ", { "tag": "NAME", "attributes": { "color": "#FF0000" } }, "!"] },
                  { "id": "price", "value": ["Only ", { "tag": "PRICE" }], "fallback": "See the offer" }
                ]
              }]
            }
            """,
            configuration: .init(device: .phone)
        )
        return try schema.extractUIConfiguration(
            id: "plain-text-test",
            withLocaleId: "en",
            envoriment: .init(
                sdkVersion: "test",
                osName: "test",
                osVersion: "test",
                deviceModel: "test",
                appBundleId: nil,
                appVersion: nil,
                appBuild: nil,
                appCurrentLocale: nil,
                userLocales: [],
                userUses24HourClock: true,
                flow: .init(
                    placementId: "test",
                    variationId: "test",
                    variationName: nil,
                    abTestName: "test",
                    name: "test",
                    products: []
                )
            )
        )
    }
}

#endif
