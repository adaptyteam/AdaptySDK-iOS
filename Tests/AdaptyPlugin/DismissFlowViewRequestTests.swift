//
//  DismissFlowViewRequestTests.swift
//  AdaptyTests
//

@testable import AdaptyPlugin
import Foundation
import Testing

struct DismissFlowViewRequestTests {
    @Test("the request reads the view id and the destroy flag")
    func decodesDestroy() throws {
        let request = try Json(##"""
        {
            "method": "adapty_ui_dismiss_flow_view",
            "id": "e2f95e1a-438c-4061-821a-331786a05c45",
            "destroy": true
        }
        """##).decode(Request.AdaptyUIDismissFlowView.self)

        #expect(request.viewId == "e2f95e1a-438c-4061-821a-331786a05c45")
        #expect(request.destroy)
    }

    @Test("a request without the destroy flag is rejected")
    func requiresDestroy() throws {
        #expect(throws: (any Error).self) {
            try Json(##"""
            {
                "method": "adapty_ui_dismiss_flow_view",
                "id": "e2f95e1a-438c-4061-821a-331786a05c45"
            }
            """##).decode(Request.AdaptyUIDismissFlowView.self)
        }
    }
}
