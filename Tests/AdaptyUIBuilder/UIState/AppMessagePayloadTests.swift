//
//  AppMessagePayloadTests.swift
//  AdaptyTests
//

@testable import AdaptyUIBuilder
import Foundation
import JavaScriptCore
import Testing

@Suite(
    "App Message Payload",
    .component("AdaptyUIBuilder"),
    .epic("JavaScript Bridge"),
    .feature("App Message"),
    .risk(.critical),
    .owner("Aleksei Valiano"),
    .layer(.unit)
)
@MainActor
struct AppMessagePayloadTests {
    private final class UnsupportedClass: Sendable {}

    private struct ConvertedStruct: JSValueConvertable {
        func toJSValue(in context: JSContext) -> JSValue {
            "converted structure".toJSValue(in: context)
        }
    }

    @Test("AppMessage delivers safely converted payload through SDKEvent")
    func safePayloadDelivery() throws {
        let context = try #require(JSContext())
        context.evaluateScript("function handleSDKEvent(event) { globalThis.received = event; return 123; }")
        let message = try VS.AppMessage(id: "message-id", payload: [
            "array": [UnsupportedClass(), NSNull(), ConvertedStruct(), ["value": 42]] as [any Sendable],
        ])
        let handler = try #require(context.objectForKeyedSubscript("handleSDKEvent"))
        let event = VS.SDKEvent.appMessage(message: message).toJSValue(in: context)
        let result = try #require(handler.call(withArguments: [event]))
        #expect(result.toInt32() == 123)
        #expect(context.evaluateScript("received.id === 'message-id' && received.name === 'app_msg' && !('screen' in received) && !('element' in received)")?.toBool() == true)
        #expect(context.evaluateScript(#"JSON.stringify(received.payload.array) === '[null,null,"converted structure",{"value":42}]'"#)?.toBool() == true)
        #expect(context.exception == nil)
    }
}
