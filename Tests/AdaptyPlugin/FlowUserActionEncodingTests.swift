//
//  FlowUserActionEncodingTests.swift
//  AdaptyTests
//

@testable import AdaptyPlugin
import AdaptyUI
import Foundation
import Testing

struct FlowUserActionEncodingTests {
    @Test("custom action encodes its arguments as JSON values")
    func customActionArguments() throws {
        let items: [any Sendable] = [NSNumber(value: 1), NSNull(), NSNumber(value: false)]
        let nested: [String: any Sendable] = ["items": items, "missing": NSNull()]
        let event = customActionEvent(arguments: ["source": "paywall", "nested": nested])

        #expect(try Json.encode(event) == Json(##"""
        {
          "id": "flow_view_did_perform_action",
          "view": {
            "id": "test-view",
            "placement_id": "test-placement",
            "variation_id": "test-variation"
          },
          "action": {
            "type": "custom",
            "value": "open_support",
            "arguments": { "source": "paywall", "nested": { "items": [1, null, false] } }
          }
        }
        """##))
    }

    @Test("custom action distinguishes omitted and empty arguments")
    func optionalArguments() throws {
        let omitted = try Json(data: customActionEvent(arguments: nil).asAdaptyJsonData)
        let empty = try Json(data: customActionEvent(arguments: [:]).asAdaptyJsonData)

        #expect(try Json(deserilized: omitted.deserilized(jsonPath: "/action")) == Json(##"""
        { "type": "custom", "value": "open_support" }
        """##))
        #expect(try Json(deserilized: empty.deserilized(jsonPath: "/action")) == Json(##"""
        { "type": "custom", "value": "open_support", "arguments": {} }
        """##))
    }

    private func customActionEvent(arguments: [String: any Sendable]?) -> FlowViewEvent.DidUserAction {
        FlowViewEvent.DidUserAction(
            view: AdaptyUI.FlowView(id: "test-view", placementId: "test-placement", variationId: "test-variation"),
            action: .custom(id: "open_support", arguments: arguments)
        )
    }
}
