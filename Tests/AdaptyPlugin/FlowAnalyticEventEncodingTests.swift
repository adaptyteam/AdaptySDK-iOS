//
//  FlowAnalyticEventEncodingTests.swift
//  AdaptyTests
//

@testable import AdaptyPlugin
import AdaptyUI
import Foundation
import Testing

struct FlowAnalyticEventEncodingTests {
    @Test("numeric analytic params keep their type when boxed as NSNumber")
    func numericParamsAreNotBridgedToBool() throws {
        let event = FlowViewEvent.DidReceiveAnalyticEvent(
            view: AdaptyUI.FlowView(
                id: "e2f95e1a-438c-4061-821a-331786a05c45",
                placementId: "PR_test_input",
                variationId: "variation"
            ),
            name: "flow_screen_showed",
            params: [
                "screen_order": NSNumber(value: 1),
                "zero": NSNumber(value: 0),
                "two": NSNumber(value: 2),
                "fraction": NSNumber(value: 1.5),
                "is_last_screen": NSNumber(value: false),
                "flag": NSNumber(value: true),
            ]
        )

        #expect(try Json.encode(event) == Json(deserilized: [
            "id": "flow_view_did_receive_analytic_event",
            "name": "flow_screen_showed",
            "view": [
                "id": "e2f95e1a-438c-4061-821a-331786a05c45",
                "placement_id": "PR_test_input",
                "variation_id": "variation",
            ],
            "params": [
                "screen_order": 1,
                "zero": 0,
                "two": 2,
                "fraction": 1.5,
                "is_last_screen": false,
                "flag": true,
            ],
        ]))
    }
}
