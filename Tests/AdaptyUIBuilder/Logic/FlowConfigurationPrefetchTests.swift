//
//  FlowConfigurationPrefetchTests.swift
//  AdaptyTests
//

#if canImport(UIKit)

@testable import AdaptyUIBuilder
import Foundation
import SwiftUI
import Testing

/// A configuration built straight from a schema sends the schema's image URLs
/// to the media prefetcher first, as the placement path does.
///
/// The image URL observer is global and is registered and fed from
/// unstructured tasks, so every URL here carries a per-test UUID and every
/// assertion waits for a delivery that contains its own URL.
@Suite(
    "AdaptyUIBuilder Tests",
    .serialized,
    .component("AdaptyUIBuilder"),
    .epic("Media Cache"),
    .feature("Prefetch From Schema"),
    .risk(.high),
    .owner("Aleksey Goncharov"),
    .layer(.unit),
    .tags(.logic)
)
@MainActor
struct FlowConfigurationPrefetchTests {
    @Test("Building a configuration from a schema prefetches its images")
    func getFlowConfiguration_sendsTheSchemaImageUrls() async throws {
        let uuid = UUID().uuidString
        let spy = try await Self.registeredSpy(uuid)
        let heroUrl = Self.url(uuid, "hero.png")

        _ = try await AdaptyUIBuilder.getFlowConfiguration(
            forSchema: Self.heroSchema(uuid),
            localeId: "en",
            products: [],
            tagResolver: nil,
            timerResolver: nil,
            assetsResolver: nil
        )

        #expect(await spy.awaitDelivery(containing: heroUrl))
    }

    @Test("Without a locale the default localization's images are prefetched")
    func getFlowConfiguration_withoutLocale_prefetchesTheDefaultLocalization() async throws {
        let uuid = UUID().uuidString
        let spy = try await Self.registeredSpy(uuid)
        let localizedUrl = Self.url(uuid, "de.png")

        _ = try await AdaptyUIBuilder.getFlowConfiguration(
            forSchema: Self.localizedSchema(uuid),
            localeId: nil,
            products: [],
            tagResolver: nil,
            timerResolver: nil,
            assetsResolver: nil
        )

        #expect(await spy.awaitDelivery(containing: localizedUrl))
    }

    @Test("The deprecated entry point prefetches and passes the custom elements resolver on")
    func deprecatedGetPaywallConfiguration_forwardsPrefetchAndResolver() async throws {
        let uuid = UUID().uuidString
        let spy = try await Self.registeredSpy(uuid)
        let heroUrl = Self.url(uuid, "hero.png")
        let stub = StubCustomElementsResolver()

        let configuration = try await AdaptyUIBuilder.getPaywallConfiguration(
            forSchema: Self.heroSchema(uuid),
            localeId: "en",
            products: [],
            tagResolver: nil,
            timerResolver: nil,
            assetsResolver: nil,
            customElementsResolver: stub
        )

        #expect(await spy.awaitDelivery(containing: heroUrl))
        let resolver = try #require(configuration.customElementsViewModel.customElementsResolver)
        // `#expect(a === b)` crashes SILGen in Swift 6.4; compare identities instead.
        #expect(ObjectIdentifier(resolver as AnyObject) == ObjectIdentifier(stub))
    }
}

private final class StubCustomElementsResolver: AdaptyUICustomElementsResolver {
    func view(forType _: String, id _: String, context _: AdaptyUICustomElementContext) -> AnyView? {
        nil
    }
}

private final class SpyImageUrlObserver: AdaptyUIImageUrlObserver, @unchecked Sendable {
    private let lock = NSLock()
    private var deliveries: [Set<URL>] = []

    func extractedImageUrls(_ urls: Set<URL>) {
        lock.lock()
        deliveries.append(urls)
        lock.unlock()
    }

    private func hasDelivery(containing url: URL) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return deliveries.contains { $0.contains(url) }
    }

    /// Waits until some delivery contains `url`, at most `timeout`.
    func awaitDelivery(containing url: URL, timeout: Duration = .seconds(5)) async -> Bool {
        let deadline = ContinuousClock.now.advanced(by: timeout)
        while ContinuousClock.now < deadline {
            if hasDelivery(containing: url) { return true }
            try? await Task.sleep(for: .milliseconds(10))
        }
        return hasDelivery(containing: url)
    }
}

private extension FlowConfigurationPrefetchTests {
    static func url(_ uuid: String, _ file: String) -> URL {
        URL(string: "https://example.com/\(uuid)/\(file)")!
    }

    /// Registers a fresh spy and proves it is the registered observer: its
    /// registration task is unordered against the send tasks, so prime until
    /// this test's prime URL reaches the spy.
    static func registeredSpy(_ uuid: String) async throws -> SpyImageUrlObserver {
        let spy = SpyImageUrlObserver()
        AdaptyUIBuilder.setImageUrlObserver(spy)

        let primeSchema = try schema(assets: asset(url(uuid, "prime.png")))
        let primeUrl = url(uuid, "prime.png")
        let deadline = ContinuousClock.now.advanced(by: .seconds(5))
        var primed = false
        while !primed, ContinuousClock.now < deadline {
            AdaptyUIBuilder.sendImageUrlsToObserver(primeSchema, forLocalId: "en")
            primed = await spy.awaitDelivery(containing: primeUrl, timeout: .milliseconds(50))
        }
        try #require(primed)
        return spy
    }

    static func heroSchema(_ uuid: String) throws -> AdaptyUISchema {
        try schema(assets: asset(url(uuid, "hero.png")))
    }

    /// The `de.png` image exists only in the default localization, which is
    /// not "en". An unknown locale id falls back to the default localization,
    /// so an "en" localization overrides the same asset id: a lookup by "en"
    /// yields `en.png`, never `de.png`.
    static func localizedSchema(_ uuid: String) throws -> AdaptyUISchema {
        try schema(
            extra: """
            "default_localization": "de",
            "localizations": [
              {
                "id": "de",
                "strings": [],
                "assets": [\(asset(url(uuid, "de.png")))]
              },
              {
                "id": "en",
                "strings": [],
                "assets": [\(asset(url(uuid, "en.png")))]
              }
            ],
            """
        )
    }

    static func asset(_ url: URL) -> String {
        #"{"id": "hero", "type": "image", "url": "\#(url.absoluteString)"}"#
    }

    static func schema(assets: String? = nil, extra: String = "") throws -> AdaptyUISchema {
        let assetsJson = assets.map { #""assets": [\#($0)],"# } ?? ""
        return try AdaptyUISchema(
            from: """
            {
              "format": "5.2.0",
              \(assetsJson)
              \(extra)
              "screens": {
                "main": {
                  "content": {
                    "type": "custom",
                    "custom_id": "source",
                    "custom_type": "test"
                  }
                }
              }
            }
            """,
            configuration: .init(device: .phone)
        )
    }
}

#endif
