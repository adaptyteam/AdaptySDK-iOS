//
//  SendAppMessageRequestTests.swift
//  AdaptyTests
//

@testable import AdaptyPlugin
import Foundation
import Testing

struct SendAppMessageRequestTests {
    @Test("the request reads both ids and every JSON value of the payload")
    func decodesPayload() throws {
        let request = try Json(##"""
        {
            "method": "adapty_ui_send_app_message",
            "id": "e2f95e1a-438c-4061-821a-331786a05c45",
            "message_id": "msg-1",
            "payload": {
                "s": "text",
                "b": true,
                "n": 1.5,
                "a": [1, "two", false],
                "o": { "nested": { "k": 0 } }
            }
        }
        """##).decode(Request.AdaptyUISendAppMessage.self)

        #expect(request.viewId == "e2f95e1a-438c-4061-821a-331786a05c45")
        #expect(request.messageId == "msg-1")
        let payload = request.payload
        #expect(payload.count == 5)
        #expect(payload["s"] as? String == "text")
        #expect(payload["b"] as? Bool == true)
        #expect(payload["n"] as? Double == 1.5)

        let array = try #require(payload["a"] as? [any Sendable])
        #expect(array.count == 3)
        #expect(array[0] as? Int == 1)
        #expect(array[1] as? String == "two")
        #expect(array[2] as? Bool == false)

        let object = try #require(payload["o"] as? [String: any Sendable])
        let nested = try #require(object["nested"] as? [String: any Sendable])
        #expect(nested["k"] as? Int == 0)
    }

    @Test("null values are kept as NSNull, in objects and in arrays")
    func keepsNulls() throws {
        let request = try Json(##"""
        {
            "method": "adapty_ui_send_app_message",
            "id": "v",
            "message_id": "m",
            "payload": { "z": null, "a": [1, null, 2], "o": { "z": null, "k": 0 } }
        }
        """##).decode(Request.AdaptyUISendAppMessage.self)

        let payload = request.payload
        #expect(payload["z"] is NSNull)
        let array = try #require(payload["a"] as? [any Sendable])
        #expect(array.count == 3)
        #expect(array[1] is NSNull)
        let object = try #require(payload["o"] as? [String: any Sendable])
        #expect(object["z"] is NSNull)
    }

    @Test("an empty payload is accepted")
    func acceptsEmptyPayload() throws {
        let request = try Json(##"""
        { "method": "adapty_ui_send_app_message", "id": "v", "message_id": "m", "payload": {} }
        """##).decode(Request.AdaptyUISendAppMessage.self)

        #expect(request.payload.isEmpty)
    }

    @Test("a request without a message id or a payload object is rejected")
    func requiresMessageIdAndPayloadObject() throws {
        #expect(throws: (any Error).self) {
            try Json(##"{ "method": "adapty_ui_send_app_message", "id": "v", "payload": {} }"##)
                .decode(Request.AdaptyUISendAppMessage.self)
        }
        #expect(throws: (any Error).self) {
            try Json(##"{ "method": "adapty_ui_send_app_message", "id": "v", "message_id": "m" }"##)
                .decode(Request.AdaptyUISendAppMessage.self)
        }
        #expect(throws: (any Error).self) {
            try Json(##"{ "method": "adapty_ui_send_app_message", "id": "v", "message_id": "m", "payload": [1] }"##)
                .decode(Request.AdaptyUISendAppMessage.self)
        }
    }

    #if canImport(UIKit)
    private struct ErrorEnvelope: Decodable {
        struct Payload: Decodable {
            let adaptyCode: Int
            let message: String

            enum CodingKeys: String, CodingKey {
                case adaptyCode = "adapty_code"
                case message
            }
        }

        let error: Payload
    }

    @Test("the method is routed end to end and reports an unknown view id as wrongParam")
    func unknownView() async throws {
        let viewId = "00000000-0000-0000-0000-000000000000"

        let response = await AdaptyPlugin.execute(
            withJson: Data(##"""
            {
                "method": "adapty_ui_send_app_message",
                "id": "\##(viewId)",
                "message_id": "m",
                "payload": {}
            }
            """##.utf8)
        )

        let envelope = try JSONDecoder().decode(ErrorEnvelope.self, from: response)

        // 3001 == wrongParam (viewNotFound); platformNotSupported or an unregistered method would fail differently.
        #expect(envelope.error.adaptyCode == 3001)
        #expect(envelope.error.message.contains(viewId))
    }
    #endif
}
