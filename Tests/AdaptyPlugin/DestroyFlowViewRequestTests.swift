//
//  DestroyFlowViewRequestTests.swift
//  AdaptyTests
//

@testable import AdaptyPlugin
import Foundation
import Testing

struct DestroyFlowViewRequestTests {
    @Test("the request reads the view id from the id key")
    func decodesViewId() throws {
        let request = try Json(##"""
        {
            "method": "adapty_ui_destroy_flow_view",
            "id": "e2f95e1a-438c-4061-821a-331786a05c45"
        }
        """##).decode(Request.AdaptyUIDestroyFlowView.self)

        #expect(request.viewId == "e2f95e1a-438c-4061-821a-331786a05c45")
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

    @Test("the method is routed end to end and reports the failing view id as wrongParam")
    func routesThroughThePluginEntryPoint() async throws {
        let viewId = "00000000-0000-0000-0000-000000000000"

        let response = await AdaptyPlugin.execute(
            withJson: Data(##"""
            {
                "method": "adapty_ui_destroy_flow_view",
                "id": "\##(viewId)"
            }
            """##.utf8)
        )

        let envelope = try JSONDecoder().decode(ErrorEnvelope.self, from: response)

        // 3001 == wrongParam; an unregistered method would fail as a decoding error.
        #expect(envelope.error.adaptyCode == 3001)
        #expect(envelope.error.message.contains(viewId))
    }
    #endif
}
