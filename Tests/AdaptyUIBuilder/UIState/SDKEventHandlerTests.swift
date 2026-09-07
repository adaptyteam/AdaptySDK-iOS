@testable import AdaptyUIBuilder
import Foundation
import Testing

@Suite("SDK event handler cache")
@MainActor
struct SDKEventHandlerTests {
    /// Repeated events reuse the first valid function even if JavaScript replaces the global property.
    @Test("Successful lookup is cached")
    func successfulLookupIsCached() {
        let state = makeState()
        state.evaluateScripts(["""
        globalThis.calls = 0;
        globalThis.lookups = 0;
        Object.defineProperty(globalThis, 'handleSDKEvent', {
            configurable: true,
            get() {
                lookups++;
                return function() {
                    calls++;
                    Object.defineProperty(globalThis, 'handleSDKEvent', {
                        configurable: true, value() { calls += 100; }
                    });
                };
            }
        });
        """])

        state.sendSDKEvent(.productsLoaded(id: "event-id"))
        state.sendSDKEvent(.productsLoaded(id: "event-id"))

        #expect(state.debug(path: "calls", filter: .withoutFunction) == "calls: 2")
        #expect(state.debug(path: "lookups", filter: .withoutFunction) == "lookups: 1")
    }

    /// An unavailable or invalid handler is retried on the next event without reloading scripts.
    @Test("Failed lookup is retried", arguments: ["undefined", "null", "42"])
    func failedLookupIsRetried(initialValue: String) {
        let state = makeState()
        state.evaluateScripts(["""
        globalThis.calls = 0;
        globalThis.lookups = 0;
        Object.defineProperty(globalThis, 'handleSDKEvent', {
            get() {
                lookups++;
                return lookups === 1 ? \(initialValue) : function() { calls++; };
            }
        });
        """])

        state.sendSDKEvent(.productsLoaded(id: "event-id"))
        #expect(state.debug(path: "calls", filter: .withoutFunction) == "calls: 0")
        state.sendSDKEvent(.productsLoaded(id: "event-id"))

        #expect(state.debug(path: "calls", filter: .withoutFunction) == "calls: 1")
        #expect(state.debug(path: "lookups", filter: .withoutFunction) == "lookups: 2")
    }

    /// Reloading scripts replaces the cached function, and removing it stops delivery to the old function.
    @Test("Script evaluation invalidates the cache")
    func scriptEvaluationInvalidatesCache() {
        let state = makeState()
        state.evaluateScripts(["""
        globalThis.calls = 0;
        globalThis.handleSDKEvent = function() { calls++; };
        """])
        state.sendSDKEvent(.productsLoaded(id: "event-id"))

        state.evaluateScripts(["globalThis.handleSDKEvent = function() { calls += 10; };"])
        state.sendSDKEvent(.productsLoaded(id: "event-id"))
        #expect(state.debug(path: "calls", filter: .withoutFunction) == "calls: 11")

        state.evaluateScripts(["delete globalThis.handleSDKEvent;"])
        state.sendSDKEvent(.productsLoaded(id: "event-id"))
        #expect(state.debug(path: "calls", filter: .withoutFunction) == "calls: 11")
    }

    private func makeState() -> VS.JSState {
        let configuration = AdaptyUIConfiguration(
            formatVersion: "5.2.0",
            id: "sdk-event-test",
            localizationId: "en",
            locale: Locale(identifier: "en"),
            isRightToLeft: false,
            environment: .init(
                sdkVersion: "test", osName: "test", osVersion: "test", deviceModel: "test",
                appBundleId: nil, appVersion: nil, appBuild: nil, appCurrentLocale: nil,
                userLocales: [], userUses24HourClock: true,
                flow: .init(placementId: "test", variationId: "test", abTestName: "test", name: "test", products: [])
            ),
            assets: [:], strings: [:], navigators: [:], screens: [:], scripts: [],
            onAppMessage: nil, showPurchaseLoader: false, showRestoreLoader: false,
            legacySelectedProducts: nil
        )
        return VS.JSState(configuration: configuration, actionHandler: nil, isInspectable: false)
    }
}
