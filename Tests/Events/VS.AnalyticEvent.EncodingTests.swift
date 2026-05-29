//
//  VS.AnalyticEvent.EncodingTests.swift
//  AdaptyTests
//
//  Regression: flow scripts call `SDK.sendAnalyticsEvent({...})`. JS numbers arrive
//  from JavaScriptCore as NSNumber (__NSCFNumber) / __NSCFBoolean. They must encode
//  into the analytics payload instead of throwing
//  `EncodingError.invalidValue ... Unsupported non encodable value type: __NSCFNumber`.
//

@testable import Adapty
@testable import AdaptyUIBuilder
import Foundation
import Testing

struct VSAnalyticEventEncodingTests {
    /// Faithfully mirrors `JSValue.toDictionary()`: JavaScriptCore yields ObjC bridge types
    /// (`__NSCFString`, `__NSCFNumber`, `__NSCFBoolean`) — NOT native Swift `String`/`Int`/`Bool`.
    /// `JSONSerialization` produces the exact same bridge types, so building params from a JSON
    /// literal reproduces the real boundary (where none of those values conform to `Encodable`).
    private func jsParams(_ json: String) -> [String: any Sendable] {
        let object = try! JSONSerialization.jsonObject(with: Data(json.utf8))
        return (object as? [AnyHashable: Any]) as? [String: any Sendable] ?? [:]
    }

    @Test("VS.AnalyticEvent encodes JS NSString/NSNumber params, keeping booleans as booleans")
    func encodesJSNumberParams() throws {
        let event = VS.AnalyticEvent(
            name: "flow_screen_showed",
            params: jsParams(#"""
            {
                "event_type": "flow_screen_showed",
                "screen_id": "screen-1",
                "screen_order": 1,
                "is_last_screen": true,
                "progress": 0.5,
                "custom_payload": null
            }
            """#)
        )

        let json = try Json.encode(event)

        // `custom_payload: null` (NSNull) is dropped, not encoded.
        #expect(json == Json(deserilized: [
            "event_type": "flow_screen_showed",
            "screen_id": "screen-1",
            "screen_order": 1,
            "is_last_screen": true,
            "progress": 0.5,
        ]))
    }
}
