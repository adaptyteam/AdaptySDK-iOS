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
    .feature("App Message Action"),
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
        /// A UIBuilder configuration omits on_app_message. Parsing succeeds and the runtime configuration keeps no action.
        @Test("Configuration without an action remains valid")
        func configurationWithoutActionRemainsValid() throws {
            let configuration = try AppMessageActionTests.configuration(action: nil)

            #expect(configuration.onAppMessage == nil)
        }

        /// A UIBuilder configuration contains a global method path. Parsing preserves every path component in the runtime action.
        @Test("A method path string is preserved")
        func methodPathIsPreserved() throws {
            let configuration = try AppMessageActionTests.configuration(
                action: ##""App.onMessage""##
            )
            let action = try #require(configuration.onAppMessage)

            #expect(action.path == ["App", "onMessage"])
        }

        /// A UIBuilder configuration contains a non-string or empty on_app_message value. Schema decoding rejects the configuration.
        @Test("Structurally invalid app-message actions are rejected by the parser", arguments: [
            ##"["App.onMessage"]"##,
            ##"{}"##,
            ##"42"##,
            ##""""##,
        ])
        func invalidActionFormsAreRejected(action: String) {
            #expect(throws: (any Error).self, "Expected invalid action: \(action)") {
                try AppMessageActionTests.configuration(action: action)
            }
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
        /// A message is sent without UI context. JavaScript receives its fields and SDK metadata nested under _message.
        @Test("Simple delivery nests app metadata")
        func simpleDeliveryFlattensMessage() throws {
            let state = try AppMessageActionTests.state(
                action: ##""App.onMessage""##,
                script: "globalThis.App = { onMessage(value) { globalThis.received = value; } };"
            )
            let message = VS.AppMessage(message: [
                "_message": "caller-value",
                "name": "hello",
                "nested": ["enabled": true],
            ])

            try state.send(message: message)

            let payload = try AppMessageActionTests.javascriptObject(in: state, path: "received")
            #expect(Set(payload.keys) == ["_message", "name", "nested"])
            #expect(payload["name"] as? String == "hello")
            let nested = try #require(payload["nested"] as? [String: Any])
            #expect(nested["enabled"] as? Bool == true)

            let meta = try #require(payload["_message"] as? [String: Any])
            #expect(Set(meta.keys) == ["id", "type"])
            #expect(meta["id"] as? String == message.id.uuidString)
            #expect(meta["type"] as? String == VS.AppMessage.Kind.app.rawValue)
        }

        /// A message is sent for a screen and custom element. JavaScript receives all SDK metadata and exact runtime context nested under _message.
        @Test("Contextual delivery nests metadata and context")
        func contextualDeliveryUsesExactPayload() throws {
            let state = try AppMessageActionTests.state(
                action: ##""App.onMessage""##,
                script: "globalThis.App = { onMessage(value) { globalThis.received = value; } };"
            )
            let screen = try #require(state.configuration.screens["main"])

            let message = VS.AppMessage(
                screenInstance: .init(
                    id: "screen-instance",
                    navigatorId: "root",
                    configuration: screen,
                    contextPath: ["Screens", "main"]
                ),
                customElement: VC.CustomElement(
                    id: "hero",
                    type: "chart",
                    assets: nil,
                    strings: nil,
                    bindings: nil,
                    properties: nil
                ),
                message: [
                    "_message": "caller-value",
                    "kind": "tap",
                ]
            )
            try state.send(message: message)

            let payload = try AppMessageActionTests.javascriptObject(in: state, path: "received")
            #expect(Set(payload.keys) == ["_message", "kind"])
            #expect(payload["kind"] as? String == "tap")

            let meta = try #require(payload["_message"] as? [String: Any])
            #expect(Set(meta.keys) == ["id", "type", "screen", "element"])
            #expect(meta["id"] as? String == message.id.uuidString)
            #expect(meta["type"] as? String == VS.AppMessage.Kind.customElement.rawValue)

            let screenObject = try #require(meta["screen"] as? [String: Any])
            #expect(Set(screenObject.keys) == ["instanceId", "navigatorId", "type", "contextPath"])
            #expect(screenObject["instanceId"] as? String == "screen-instance")
            #expect(screenObject["navigatorId"] as? String == "root")
            #expect(screenObject["type"] as? String == "main")
            #expect(screenObject["contextPath"] as? String == "Screens.main")

            let customElement = try #require(meta["element"] as? [String: Any])
            #expect(Set(customElement.keys) == ["id", "type"])
            #expect(customElement["id"] as? String == "hero")
            #expect(customElement["type"] as? String == "chart")
        }

        /// An app message targets an SDK method. The existing SDK dispatcher receives caller fields plus nested SDK metadata.
        @Test("SDK action receives the flattened message object")
        func sdkActionReceivesFlattenedMessage() throws {
            let handler = MockActionHandler()
            let state = try AppMessageActionTests.state(
                action: ##""SDK.sendAnalyticsEvent""##,
                actionHandler: handler
            )
            let message = VS.AppMessage(message: [
                "name": "app_message",
                "channel": "native",
                "source": "application",
            ])

            try state.send(message: message)

            let event = try #require(handler.analyticsEvents.only)
            #expect(event.name == "app_message")
            #expect(event.params["channel"] as? String == "native")
            #expect(event.params["source"] as? String == "application")
            #expect(event.params["id"] == nil)
            #expect(event.params["type"] == nil)

            let meta = try #require(event.params["_message"] as? [String: Any])
            #expect(Set(meta.keys) == ["id", "type"])
            #expect(meta["id"] as? String == message.id.uuidString)
            #expect(meta["type"] as? String == VS.AppMessage.Kind.app.rawValue)
        }

        /// A message is sent without configuring on_app_message. The caller receives the existing method-not-found error for that field.
        @Test("Missing action returns jsMethodNotFound for on_app_message")
        func missingActionReturnsMethodNotFound() throws {
            let state = try AppMessageActionTests.state(action: nil)

            do {
                try state.send(message: .init(message: [:]))
                Issue.record("Expected jsMethodNotFound")
            } catch {
                guard case let .jsMethodNotFound(path) = error else {
                    Issue.record("Unexpected error: \(error)")
                    return
                }
                #expect(path == "on_app_message")
            }
        }

        /// A configured path references a missing JavaScript object or method. Existing resolution errors are preserved.
        @Test("Missing JS object and method keep existing errors")
        func missingJavaScriptTargetsKeepExistingErrors() throws {
            let missingObject = try AppMessageActionTests.state(
                action: ##""Missing.onMessage""##
            )
            do {
                try missingObject.send(message: .init(message: [:]))
                Issue.record("Expected jsObjectNotFound")
            } catch {
                guard case let .jsObjectNotFound(path) = error else {
                    Issue.record("Unexpected error: \(error)")
                    return
                }
                #expect(path == "Missing")
            }

            let missingMethod = try AppMessageActionTests.state(
                action: ##""App.missing""##,
                script: "globalThis.App = {};"
            )
            do {
                try missingMethod.send(message: .init(message: [:]))
                Issue.record("Expected jsMethodNotFound")
            } catch {
                guard case let .jsMethodNotFound(path) = error else {
                    Issue.record("Unexpected error: \(error)")
                    return
                }
                #expect(path == "App.missing")
            }
        }

        /// A JavaScript handler throws synchronously. The existing exception callback receives the diagnostic message.
        @Test("Synchronous JS exception stays on the didReceiveError route")
        func synchronousJavaScriptExceptionUsesErrorHandler() throws {
            let handler = MockActionHandler()
            let state = try AppMessageActionTests.state(
                action: ##""App.onMessage""##,
                script: "globalThis.App = { onMessage() { throw new Error('boom'); } };",
                actionHandler: handler
            )

            try state.send(message: .init(message: [:]))

            let error = try #require(handler.didReceiveErrors.only)
            #expect(error.contains("boom"))
        }

        /// A JavaScript handler returns a rejected Promise. Sending remains synchronous and does not turn the rejection into a thrown Swift error.
        @Test("Rejected Promise is not converted into a synchronous throw")
        func rejectedPromiseIsNotSynchronousThrow() throws {
            let state = try AppMessageActionTests.state(
                action: ##""App.onMessage""##,
                script: """
                globalThis.App = {
                  onMessage() {
                    globalThis.promiseCallCount = (globalThis.promiseCallCount || 0) + 1;
                    return Promise.reject(new Error('later'));
                  }
                };
                """
            )

            try state.send(message: .init(message: [:]))

            #expect(state.debug(path: "promiseCallCount") == "promiseCallCount: 1")
        }
    }
}

private extension AppMessageActionTests {
    static func configuration(
        action: String?,
        script: String = ""
    ) throws -> AdaptyUIConfiguration {
        let actionProperty = action.map { #", "on_app_message": \#($0)"# } ?? ""
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
              \(actionProperty)
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
        action: String?,
        script: String = "",
        actionHandler: AdaptyUIActionHandler? = nil
    ) throws -> AdaptyUIState {
        let state = try AdaptyUIState(
            configuration: configuration(action: action, script: script),
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
