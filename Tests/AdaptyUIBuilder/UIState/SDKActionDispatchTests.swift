@testable import AdaptyUIBuilder
import Foundation
import JavaScriptCore
import Testing

@Suite("SDK action dispatch", .tags(.codable))
@MainActor
struct SDKActionDispatchTests {
    @Test("An explicit URL takes priority over stringId, including invalid URLs", arguments: [
        (Json(#"{"url":"https://example.com"}"#), ["https://example.com"], [String]()),
        (Json(#"{"stringId":"link"}"#), [String](), ["link"]),
        (Json(#"{"url":"https://example.com","stringId":"link"}"#), ["https://example.com"], [String]()),
        (Json(#"{"url":"http://[","stringId":"link"}"#), [String](), [String]()),
        (Json(#"{"url":null,"stringId":"link"}"#), [String](), [String]()),
        (Json(#"{"url":42,"stringId":"link"}"#), [String](), [String]()),
        (Json(#"{}"#), [String](), [String]()),
    ])
    func openURLPriority(params: Json, expectedURLs: [String], expectedStringIds: [String]) throws {
        for useJavaScript in [false, true] {
            let handler = ActionHandler()
            let dispatcher = VS.JSActionDispatcher(handler, try configuration())

            if useJavaScript {
                let context = try #require(JSContext())
                context.globalObject.setValue(dispatcher, forProperty: "SDK")
                context.evaluateScript("SDK.openUrl(\(String(decoding: params.data, as: UTF8.self)))")
                #expect(context.exception == nil)
            } else {
                let action = try Json(deserilized: [
                    "func": "SDK.openUrl",
                    "scope": "global",
                    "params": params.deserilized,
                ]).decode(VC.Action.self)
                let method = try #require(action.sdkMethod)
                #expect(dispatcher.fastExecute(method, params: action.params))
            }

            #expect(handler.openedURLs.map(\.absoluteString) == expectedURLs)
            #expect(handler.openedStringIds == expectedStringIds)
        }
    }

    @Test("JSON timer actions accept integer and fractional numbers", arguments: [
        (Json(##"{"func":"SDK.setTimer","scope":"global","params":{"id":"timer","duration":60}}"##), "duration", 60.0),
        (Json(##"{"func":"SDK.setTimer","scope":"global","params":{"id":"timer","duration":0.25}}"##), "duration", 0.25),
        (Json(##"{"func":"SDK.setTimer","scope":"global","params":{"id":"timer","endAt":1700000000000}}"##), "endAt", 1700000000.0),
    ])
    func timerNumbers(json: Json, parameter: String, expected: Double) throws {
        let action = try json.decode(VC.Action.self)
        let handler = ActionHandler()
        let dispatcher = VS.JSActionDispatcher(handler, try configuration())
        let method = try #require(action.sdkMethod)

        #expect(dispatcher.fastExecute(method, params: action.params))

        if parameter == "duration" {
            #expect(handler.timerDurations == [expected])
            #expect(handler.timerEndDates.isEmpty)
        } else {
            #expect(handler.timerEndDates.map(\.timeIntervalSince1970) == [expected])
            #expect(handler.timerDurations.isEmpty)
        }
    }

    @Test("Timer parameters prefer endAt and default invalid behavior to continue", arguments: [
        (Json(#"{"id":"t","endAt":2000000000000}"#), [2000000000.0], [Double](), [String]()),
        (Json(#"{"id":"t","endAt":0}"#), [0.0], [Double](), [String]()),
        (Json(#"{"id":"t","duration":60}"#), [Double](), [60.0], ["continue"]),
        (Json(#"{"id":"t","duration":0.25}"#), [Double](), [0.25], ["continue"]),
        (Json(#"{"id":"t","duration":0}"#), [Double](), [0.0], ["continue"]),
        (Json(#"{"id":"t","duration":-1}"#), [Double](), [-1.0], ["continue"]),
        (Json(#"{"id":"t","duration":60,"behavior":"continue"}"#), [Double](), [60.0], ["continue"]),
        (Json(#"{"id":"t","duration":60,"behavior":"restart"}"#), [Double](), [60.0], ["restart"]),
        (Json(#"{"id":"t","duration":60,"behavior":"persisted"}"#), [Double](), [60.0], ["persisted"]),
        (Json(#"{"id":"t","duration":60,"behavior":"custom"}"#), [Double](), [60.0], ["custom"]),
        (Json(#"{"id":"t","endAt":2000000000000,"duration":60}"#), [2000000000.0], [Double](), [String]()),
        (Json(#"{"id":"t","endAt":2000000000000,"behavior":"persisted"}"#), [2000000000.0], [Double](), [String]()),
        (Json(#"{"id":"t","endAt":2000000000000,"duration":60,"behavior":"restart"}"#), [2000000000.0], [Double](), [String]()),
        (Json(#"{"id":"t","endAt":2000000000000,"duration":null}"#), [2000000000.0], [Double](), [String]()),
        (Json(#"{"id":"t","endAt":2000000000000,"behavior":null}"#), [2000000000.0], [Double](), [String]()),
        (Json(#"{"id":"t","endAt":"bad","duration":60}"#), [Double](), [Double](), [String]()),
        (Json(#"{"id":"t","endAt":null,"duration":60}"#), [Double](), [Double](), [String]()),
        (Json(#"{"id":"t","endAt":"bad"}"#), [Double](), [Double](), [String]()),
        (Json(#"{"id":"t","endAt":null}"#), [Double](), [Double](), [String]()),
        (Json(#"{"id":"t","endAt":true}"#), [0.001], [Double](), [String]()),
        (Json(#"{"id":"t","duration":true}"#), [Double](), [1.0], ["continue"]),
        (Json(#"{"id":"t","duration":"60"}"#), [Double](), [Double](), [String]()),
        (Json(#"{"id":"t","duration":null}"#), [Double](), [Double](), [String]()),
        (Json(#"{"id":"t"}"#), [Double](), [Double](), [String]()),
        (Json(#"{"id":"t","behavior":"restart"}"#), [Double](), [Double](), [String]()),
        (Json(#"{"id":"t","duration":60,"behavior":"other"}"#), [Double](), [60.0], ["continue"]),
        (Json(#"{"id":"t","duration":60,"behavior":null}"#), [Double](), [60.0], ["continue"]),
        (Json(#"{"id":"t","duration":60,"behavior":1}"#), [Double](), [60.0], ["continue"]),
    ])
    func timerParameters(params: Json, expectedEndDates: [Double], expectedDurations: [Double], expectedBehaviors: [String]) throws {
        for useJavaScript in [false, true] {
            let handler = ActionHandler()
            let dispatcher = VS.JSActionDispatcher(handler, try configuration())

            if useJavaScript {
                let context = try #require(JSContext())
                context.globalObject.setValue(dispatcher, forProperty: "SDK")
                context.evaluateScript("SDK.setTimer(\(String(decoding: params.data, as: UTF8.self)))")
                #expect(context.exception == nil)
            } else {
                let action = try Json(deserilized: [
                    "func": "SDK.setTimer",
                    "scope": "global",
                    "params": params.deserilized,
                ]).decode(VC.Action.self)
                let method = try #require(action.sdkMethod)
                #expect(dispatcher.fastExecute(method, params: action.params))
            }

            #expect(handler.timerEndDates == expectedEndDates.map { Date(timeIntervalSince1970: $0) })
            #expect(handler.timerDurations == expectedDurations)
            #expect(handler.timerBehaviors.map(\.rawValue) == expectedBehaviors)
        }
    }

    @Test("Non-finite timer numbers are rejected", arguments: [
        "{id:'t',endAt:NaN}",
        "{id:'t',endAt:Infinity}",
        "{id:'t',duration:NaN}",
        "{id:'t',duration:-Infinity}",
    ])
    func nonFiniteTimerNumbers(params: String) throws {
        let handler = ActionHandler()
        let dispatcher = VS.JSActionDispatcher(handler, try configuration())
        let context = try #require(JSContext())
        context.globalObject.setValue(dispatcher, forProperty: "SDK")

        context.evaluateScript("SDK.setTimer(\(params))")

        #expect(context.exception == nil)
        #expect(handler.timerEndDates.isEmpty)
        #expect(handler.timerDurations.isEmpty)
    }

    @Test("Analytics parameters filter routing flags and preserve user data")
    func customerAnalyticsParameters() throws {
        let json = Json(##"""
        {
          "func": "SDK.sendAnalyticsEvent",
          "scope": "global",
          "params": {
            "name": "case_sdk_action",
            "instanceId": "screen-instance",
            "isCustomerEvent": true,
            "isBackendEvent": true,
            "source": "json_sdk_action",
            "metadata": { "isBackendEvent": false, "values": [42, null, "value"] }
          }
        }
        """##)
        let action = try json.decode(VC.Action.self)
        let handler = ActionHandler()
        let dispatcher = VS.JSActionDispatcher(handler, try configuration())
        let method = try #require(action.sdkMethod)

        #expect(dispatcher.fastExecute(method, params: action.params))

        let event = try #require(handler.events.first)
        let expectedCustomerParams = Json(##"""
        {
          "name": "case_sdk_action",
          "instanceId": "screen-instance",
          "source": "json_sdk_action",
          "metadata": { "isBackendEvent": false, "values": [42, null, "value"] }
        }
        """##)
        #expect(Json(deserilized: event.params(with: [.name, .instanceId])) == expectedCustomerParams)
        #expect(Json(deserilized: event.params()) == Json(##"""
        {
          "source": "json_sdk_action",
          "metadata": { "isBackendEvent": false, "values": [42, null, "value"] }
        }
        """##))
        #expect(event.name == "case_sdk_action")
        #expect(event.screenInstanceId == "screen-instance")
        #expect(event.isCustomer)
        #expect(event.isBackend)
        #expect(try Json(deserilized: event.params(with: Set(VS.AnalyticEvent.ParamsInternalKeys.allCases)))
            == Json(deserilized: json.deserilized(jsonPath: "/params")))
    }

    @Test("Only a direct global SDK method uses fast execution", arguments: [
        (Json(##"{"func":"SDK.sendAnalyticsEvent","scope":"global","params":{"name":"test"}}"##), true),
        (Json(##"{"func":"SDK.sendAnalyticsEvent","scope":"screen","params":{"name":"test"}}"##), false),
        (Json(##"{"func":"Other.sendAnalyticsEvent","scope":"global","params":{"name":"test"}}"##), false),
        (Json(##"{"func":"SDK.sendAnalyticsEvent.nested","scope":"global","params":{"name":"test"}}"##), false),
        (Json(##"{"func":"SDK.unknownMethod","scope":"global","params":{"name":"test"}}"##), false),
        (Json(##"{"func":"SDK","scope":"global","params":{"name":"test"}}"##), false),
    ])
    func fastExecutionRouting(json: Json, expected: Bool) throws {
        let handler = ActionHandler()
        let dispatcher = VS.JSActionDispatcher(handler, try configuration())
        let action = try json.decode(VC.Action.self)

        let handled = action.sdkMethod.map { dispatcher.fastExecute($0, params: action.params) } ?? false
        #expect(handled == expected)
        #expect(handler.events.count == (expected ? 1 : 0))
    }

    private func configuration() throws -> AdaptyUIConfiguration {
        let schema = try AdaptyUISchema(
            from: Json(##"""
            {
              "format": "5.2.0",
              "screens": {
                "main": { "content": { "type": "box" } }
              }
            }
            """##).data,
            configuration: .init(device: .phone)
        )
        return try schema.extractUIConfiguration(
            id: "sdk-action-test",
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

private final class ActionHandler: AdaptyUIActionHandler {
    private(set) var events = [VS.AnalyticEvent]()
    private(set) var timerDurations = [TimeInterval]()
    private(set) var timerEndDates = [Date]()
    private(set) var timerBehaviors = [VS.SetTimerBehavior]()
    private(set) var openedURLs = [URL]()
    private(set) var openedStringIds = [String]()

    func sendAnalyticsEvent(_ event: VS.AnalyticEvent) { events.append(event) }
    func jsException(_ message: String) { Issue.record("Unexpected JavaScript exception: \(message)") }
    func openUrl(url: URL, openIn _: VC.Action.WebOpenInParameter) { openedURLs.append(url) }
    func openUrl(stringId: String, openIn _: VC.Action.WebOpenInParameter) { openedStringIds.append(stringId) }
    func userCustomAction(id _: String, arguments _: [String: any Sendable]?) {}
    func purchaseProduct(productId _: String, service _: VC.Action.PaymentService, callback _: VS.JSAction?) {}
    func restorePurchases(callback _: VS.JSAction?) {}
    func closeAll() {}
    func selectProduct(productId _: String) {}
    func openScreen(instance _: VS.ScreenInstance, transitionId _: String) {}
    func closeScreen(navigatorId _: String, transitionId _: String) {}
    func changeFocus(id _: String?) {}
    func setTimer(id _: String, endAt: Date, callback _: VS.JSAction?) { timerEndDates.append(endAt) }
    func setTimer(id _: String, duration: TimeInterval, behavior: VS.SetTimerBehavior, callback _: VS.JSAction?) {
        timerDurations.append(duration)
        timerBehaviors.append(behavior)
    }
    func moveScroll(instanceId _: String, kind _: VS.ScrollKind, value _: VS.ScrollValue) {}
    func sendEvents(instanceId _: String?, eventIds _: [String]) {}
    func showAppRate() {}
    func showAlertDialog(params _: VS.ShowAlertDialogParameters, callback _: VS.JSAction?) {}
    func showRequestPermission(params _: VS.ShowRequestPermissionParameters, callback _: VS.JSAction?) {}
}
