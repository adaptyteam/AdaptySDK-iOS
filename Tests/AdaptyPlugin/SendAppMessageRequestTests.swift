//
//  SendAppMessageRequestTests.swift
//  AdaptyTests
//

@testable import AdaptyPlugin
import Foundation
import Testing

struct SendAppMessageRequestTests {
    @Test("the request reads the view id and keeps every JSON value of the payload")
    func decodesPayload() throws {
        let request = try Json(##"""
        {
            "method": "adapty_ui_send_app_message",
            "id": "e2f95e1a-438c-4061-821a-331786a05c45",
            "payload": {
                "s": "text",
                "b": true,
                "n": 1.5,
                "z": null,
                "a": [1, "two", false],
                "o": { "nested": { "k": 0 } }
            }
        }
        """##).decode(Request.AdaptyUISendAppMessage.self)

        #expect(request.viewId == "e2f95e1a-438c-4061-821a-331786a05c45")
        let payload = request.payload
        #expect(payload.count == 6)
        #expect(payload["s"] as? String == "text")
        #expect(payload["b"] as? Bool == true)
        #expect(payload["n"] as? Double == 1.5)
        #expect(payload["z"] is NSNull)

        let array = try #require(payload["a"] as? [any Sendable])
        #expect(array.count == 3)
        #expect(array[0] as? Int == 1)
        #expect(array[1] as? String == "two")
        #expect(array[2] as? Bool == false)

        let object = try #require(payload["o"] as? [String: any Sendable])
        let nested = try #require(object["nested"] as? [String: any Sendable])
        #expect(nested["k"] as? Int == 0)
    }

    @Test("an empty payload is accepted")
    func acceptsEmptyPayload() throws {
        let request = try Json(##"""
        { "method": "adapty_ui_send_app_message", "id": "v", "payload": {} }
        """##).decode(Request.AdaptyUISendAppMessage.self)

        #expect(request.payload.isEmpty)
    }

    @Test("a request without a payload object is rejected")
    func requiresPayloadObject() throws {
        #expect(throws: (any Error).self) {
            try Json(##"{ "method": "adapty_ui_send_app_message", "id": "v" }"##)
                .decode(Request.AdaptyUISendAppMessage.self)
        }
        #expect(throws: (any Error).self) {
            try Json(##"{ "method": "adapty_ui_send_app_message", "id": "v", "payload": [1] }"##)
                .decode(Request.AdaptyUISendAppMessage.self)
        }
    }

    @Test("an unknown view is reported as not found")
    @MainActor
    func unknownView() async throws {
        let request = try Json(##"""
        { "method": "adapty_ui_send_app_message", "id": "missing", "payload": {} }
        """##).decode(Request.AdaptyUISendAppMessage.self)

        await #expect(throws: (any Error).self) {
            try await request.execute()
        }
    }
}
