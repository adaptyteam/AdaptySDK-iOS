@testable import AdaptyUIBuilder
import Foundation
import Testing

@Suite("SDK action dispatch", .tags(.codable))
@MainActor
struct SDKActionDispatchTests {
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

    func sendAnalyticsEvent(_ event: VS.AnalyticEvent) { events.append(event) }
    func jsException(_ message: String) { Issue.record("Unexpected JavaScript exception: \(message)") }
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
    func setTimer(id _: String, endAt: Date, callback _: VS.JSAction?) { timerEndDates.append(endAt) }
    func setTimer(id _: String, duration: TimeInterval, behavior _: VS.SetTimerBehavior, callback _: VS.JSAction?) { timerDurations.append(duration) }
    func moveScroll(instanceId _: String, kind _: VS.ScrollKind, value _: VS.ScrollValue) {}
    func sendEvents(instanceId _: String?, eventIds _: [String]) {}
    func showAppRate() {}
    func showAlertDialog(params _: VS.ShowAlertDialogParameters, callback _: VS.JSAction?) {}
    func showRequestPermission(params _: VS.ShowRequestPermissionParameters, callback _: VS.JSAction?) {}
}
