//
//  FlowRenderingUnsupportedTests.swift
//  AdaptyTests
//

#if canImport(UIKit)

import AdaptyPlugin
import AdaptyUI
import Foundation
import Testing

@MainActor
struct FlowRenderingUnsupportedTests {
    private struct ErrorEnvelope: Decodable {
        struct Payload: Decodable {
            let adaptyCode: Int

            enum CodingKeys: String, CodingKey {
                case adaptyCode = "adapty_code"
            }
        }

        let error: Payload
    }

    @Test(
        "flow view requests report platformNotSupported where flows are not rendered",
        arguments: [
            #"{"method": "adapty_ui_create_flow_view", "flow": {"placement": {"developer_id": "placement", "audience_name": "audience", "revision": 1, "ab_test_name": "test", "placement_audience_version_id": "version"}, "flow_id": "flow", "flow_name": "flow", "variation_id": "variation", "variations": []}}"#,
            #"{"method": "adapty_ui_present_flow_view", "id": "view"}"#,
            #"{"method": "adapty_ui_dismiss_flow_view", "id": "view", "destroy": true}"#,
            #"{"method": "adapty_ui_destroy_flow_view", "id": "view"}"#,
            #"{"method": "adapty_ui_show_dialog", "id": "view", "configuration": {"default_action_title": "OK"}}"#,
        ]
    )
    func requestFails(json: String) async throws {
        let response = await AdaptyUI.Plugin.$isFlowRenderingSupported.withValue(false) {
            await AdaptyPlugin.execute(withJson: Data(json.utf8))
        }

        let envelope = try JSONDecoder().decode(ErrorEnvelope.self, from: response)

        // With rendering available the same requests fail later: create on the
        // flow itself, the others as wrongParam (3001) on the unknown view id.
        #expect(envelope.error.adaptyCode == AdaptyUIError.Code.platformNotSupported.rawValue)
    }
}

#endif
