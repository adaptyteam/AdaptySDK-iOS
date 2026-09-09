//
//  AppMessageActionTests.swift
//  AdaptyTests
//
//  Created by Adapty on 03.09.2026.
//

@testable import AdaptyUIBuilder
import Foundation
import JavaScriptCore
import Testing

@Suite(
    "AdaptyUIBuilder Tests",
    .component("AdaptyUIBuilder"),
    .epic("App Message"),
    .feature("App Message Delivery"),
    .risk(.critical),
    .owner("Aleksei Valiano"),
    .layer(.unit),
    .tags(.codable)
)
enum AppMessageActionTests {
    @Suite(
        "App Message Configuration",
        .story("App Message Configuration")
    )
    struct AppMessageConfigurationTests {
        @Test("Configuration preserves the shared SDK handler script")
        func configurationPreservesScript() throws {
            let script = "function handleSDKEvent(event) { globalThis.received = event; }"
            let configuration = try AppMessageActionTests.configuration(script: script)
            #expect(configuration.scripts == [script])
        }
    }

    @Suite(
        "App Message Runtime Models",
        .story("App Message Runtime Models")
    )
    struct AppMessageRuntimeModelTests {
        /// A custom element instance is converted to JavaScript. Only its stable identifier and type are exposed.
        @Test("Custom element instance serializes only stable identity")
        func customElementInstanceSerializesOnlyStableIdentity() throws {
            let context = try #require(JSContext())
            let instance = VS.CustomElementInstance(id: "hero", type: "chart")
            let object = try #require(instance.toJSValue(in: context).toDictionary())

            #expect(Set(object.keys.compactMap { $0 as? String }) == ["id", "type"])
            #expect(object["id"] as? String == "hero")
            #expect(object["type"] as? String == "chart")
        }
    }

    @Suite(
        "App Message Delivery",
        .story("App Message Delivery")
    )
    @MainActor
    struct AppMessageDeliveryTests {
        /// UIState routes a message through the shared SDK event handler without a configured action.
        @Test("Simple delivery uses SDKEvent and preserves caller fields")
        func simpleDelivery() throws {
            let state = try AppMessageActionTests.state(
                script: "function handleSDKEvent(event) { globalThis.received = event; globalThis.calls = (globalThis.calls || 0) + 1; }"
            )
            let message = try VS.AppMessage(id: "caller-id", payload: [
                "_message": "caller-value", "name": "hello", "id": "payload-id",
                "payload": "payload-value", "screen": "caller-screen", "element": "caller-element",
            ])
            try state.send(message: message)
            try state.send(message: message)

            let event = try AppMessageActionTests.javascriptObject(in: state, path: "received")
            #expect(Set(event.keys) == ["id", "name", "payload"])
            #expect(event["id"] as? String == "caller-id")
            #expect(event["name"] as? String == "app_msg")
            let payload = try #require(event["payload"] as? [String: Any])
            #expect(payload["name"] as? String == "hello")
            #expect(payload["id"] as? String == "payload-id")
            #expect(payload["_message"] as? String == "caller-value")
            #expect(payload["payload"] as? String == "payload-value")
            #expect(payload["screen"] as? String == "caller-screen")
            #expect(payload["element"] as? String == "caller-element")
            #expect(state.debug(path: "calls") == "calls: 2")
        }

        /// Both contextual initializers deliver the exact screen and custom-element identities.
        @Test("Contextual delivery includes screen and element", arguments: [false, true])
        func contextualDelivery(useConfigurationElement: Bool) throws {
            let state = try AppMessageActionTests.state(
                script: "function handleSDKEvent(event) { globalThis.received = event; }"
            )
            let screen = try #require(state.configuration.screens["main"])
            let screenInstance = VS.ScreenInstance(
                id: "screen-instance", navigatorId: "root", configuration: screen,
                contextPath: ["Screens", "main"]
            )
            let message: VS.AppMessage
            if useConfigurationElement {
                message = try VS.AppMessage(
                    id: "context-id", screenInstance: screenInstance,
                    customElement: VC.CustomElement(
                        id: "hero", type: "chart", assets: nil, strings: nil, bindings: nil, payload: nil
                    ),
                    payload: ["kind": "tap"]
                )
            } else {
                message = try VS.AppMessage(
                    id: "context-id", screenInstance: screenInstance,
                    elementInstance: .init(id: "hero", type: "chart"), payload: ["kind": "tap"]
                )
            }
            try state.send(message: message)
            let event = try AppMessageActionTests.javascriptObject(in: state, path: "received")
            #expect(Set(event.keys) == ["id", "name", "screen", "element", "payload"])
            #expect(event["id"] as? String == "context-id")
            #expect(event["name"] as? String == "custom_element_msg")
            let payload = try #require(event["payload"] as? [String: Any])
            #expect(payload["kind"] as? String == "tap")
            let screenObject = try #require(event["screen"] as? [String: Any])
            #expect(Set(screenObject.keys) == ["instanceId", "navigatorId", "type", "contextPath"])
            #expect(screenObject["instanceId"] as? String == "screen-instance")
            #expect(screenObject["navigatorId"] as? String == "root")
            #expect(screenObject["type"] as? String == "main")
            #expect(screenObject["contextPath"] as? String == "Screens.main")
            let element = try #require(event["element"] as? [String: Any])
            #expect(Set(element.keys) == ["id", "type"])
            #expect(element["id"] as? String == "hero")
            #expect(element["type"] as? String == "chart")
        }

        /// Scripts can explicitly forward payload fields to an existing SDK action.
        @Test("Shared handler can forward payload to SDK")
        func handlerCanCallSDK() throws {
            let handler = MockActionHandler()
            let state = try AppMessageActionTests.state(
                script: "function handleSDKEvent(event) { SDK.sendAnalyticsEvent(event.payload); }",
                actionHandler: handler
            )
            try state.send(message: .init(id: "analytics-id", payload: [
                "name": "app_message", "channel": "native", "source": "application",
            ]))
            let event = try #require(handler.analyticsEvents.only)
            #expect(event.name == "app_message")
            #expect(event.params["channel"] as? String == "native")
            #expect(event.params["source"] as? String == "application")
            #expect(event.params["id"] == nil)
            #expect(event.params["_message"] == nil)
        }

        /// Missing or invalid handlers skip the event without throwing an action-resolution error.
        @Test("Unavailable SDK handler does not throw", arguments: ["undefined", "null", "42"])
        func unavailableHandler(value: String) throws {
            let state = try AppMessageActionTests.state(
                script: "globalThis.handleSDKEvent = \(value);"
            )
            try state.send(message: .init(id: "empty", payload: [:]))
        }

        /// An empty payload remains an object and is delivered exactly once.
        @Test("Empty payload reaches the shared SDK handler")
        func emptyPayload() throws {
            let state = try AppMessageActionTests.state(
                script: """
                globalThis.calls = 0;
                function handleSDKEvent(event) { calls++; globalThis.received = event; }
                """
            )
            try state.send(message: .init(id: "empty", payload: [:]))
            #expect(state.debug(path: "calls") == "calls: 1")
            let event = try AppMessageActionTests.javascriptObject(in: state, path: "received")
            let payload = try #require(event["payload"] as? [String: Any])
            #expect(payload.isEmpty)
        }

        /// A synchronous exception still reaches the existing native diagnostic callback.
        @Test("Synchronous JS exception stays on the didReceiveError route")
        func synchronousJavaScriptExceptionUsesErrorHandler() throws {
            let handler = MockActionHandler()
            let state = try AppMessageActionTests.state(
                script: "function handleSDKEvent() { throw new Error('boom'); }",
                actionHandler: handler
            )
            try state.send(message: .init(id: "throwing", payload: [:]))
            let error = try #require(handler.didReceiveErrors.only)
            #expect(error.contains("boom"))
        }

        /// A rejected Promise is not awaited or converted into a synchronous Swift throw.
        @Test("Rejected Promise is not converted into a synchronous throw")
        func rejectedPromiseIsNotSynchronousThrow() throws {
            let state = try AppMessageActionTests.state(
                script: """
                function handleSDKEvent() {
                  globalThis.promiseCallCount = (globalThis.promiseCallCount || 0) + 1;
                  return Promise.reject(new Error('later'));
                }
                """
            )
            try state.send(message: .init(id: "promise", payload: [:]))
            #expect(state.debug(path: "promiseCallCount") == "promiseCallCount: 1")
        }
    }
}

private extension AppMessageActionTests {
    static func configuration(
        script: String = ""
    ) throws -> AdaptyUIConfiguration {
        let script = Json(deserilized: script)

        let schema = try AdaptyUISchema(
            from: """
            {
              "format": "5.2.0",
              "screens": {
                "main": {
                  "content": {
                    "type": "custom",
                    "custom_id": "source",
                    "custom_type": "test"
                  }
                }
              },
              "scripts": [
                {
                  "type": "js",
                  "content": \(script)
                }
              ]
            }
            """,
            configuration: .init(device: .phone)
        )
        return try schema.extractUIConfiguration(
            id: "app-message-test",
            withLocaleId: "en",
            envoriment: .appMessageTest
        )
    }

    @MainActor
    static func state(
        script: String = "",
        actionHandler: AdaptyUIActionHandler? = nil
    ) throws -> AdaptyUIState {
        let state = try AdaptyUIState(
            configuration: configuration(script: script),
            actionHandler: actionHandler
        )
        state.startOnce()
        return state
    }

    @MainActor
    static func javascriptObject(
        in state: AdaptyUIState,
        path: String
    ) throws -> [String: Any] {
        let prefix = "\(path): "
        let value = state.debug(path: path)
        guard value.hasPrefix(prefix) else {
            Issue.record("Unexpected debug value: \(value)")
            throw TestError.invalidJavaScriptDebugValue
        }
        let json = value.dropFirst(prefix.count)
        let data = Data(json.utf8)
        guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            Issue.record("Expected a JavaScript object: \(value)")
            throw TestError.invalidJavaScriptDebugValue
        }
        return object
    }

    enum TestError: Error {
        case invalidJavaScriptDebugValue
    }
}

private extension VC.EnvironmentConstants {
    static let appMessageTest = Self(
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
            abTestName: "test",
            name: "test",
            products: []
        )
    )
}

private extension Array {
    var only: Element? {
        count == 1 ? first : nil
    }
}

private final class MockActionHandler: AdaptyUIActionHandler {
    private(set) var didReceiveErrors = [String]()
    private(set) var analyticsEvents = [VS.AnalyticEvent]()

    func jsException(_ message: String) {
        didReceiveErrors.append(message)
    }

    func sendAnalyticsEvent(_ event: VS.AnalyticEvent) {
        analyticsEvents.append(event)
    }

    func openUrl(url _: URL, openIn _: VC.Action.WebOpenInParameter) {}
    func openUrl(stringId _: String, openIn _: VC.Action.WebOpenInParameter) {}
    func userCustomAction(id _: String) {}
    func purchaseProduct(productId _: String, service _: VC.Action.PaymentService, callback _: VS.JSAction?) {}
    func restorePurchases(callback _: VS.JSAction?) {}
    func closeAll() {}
    func selectProduct(productId _: String) {}
    func openScreen(instance _: VS.ScreenInstance, transitionId _: String) {}
    func closeScreen(navigatorId _: String, transitionId _: String) {}
    func changeFocus(id _: String?) {}
    func setTimer(id _: String, endAt _: Date, callback _: VS.JSAction?) {}
    func setTimer(id _: String, duration _: TimeInterval, behavior _: VS.SetTimerBehavior, callback _: VS.JSAction?) {}
    func moveScroll(instanceId _: String, kind _: VS.ScrollKind, value _: VS.ScrollValue) {}
    func sendEvents(instanceId _: String?, eventIds _: [String]) {}
    func showAppRate() {}
    func showAlertDialog(params _: VS.ShowAlertDialogParameters, callback _: VS.JSAction?) {}
    func showRequestPermission(params _: VS.ShowRequestPermissionParameters, callback _: VS.JSAction?) {}
}
