//
//  FlowViewEvent.DidRequestAppReview.swift
//  AdaptyPlugin
//

import Adapty
import AdaptyUI
import Foundation

extension FlowViewEvent {
    struct DidRequestAppReview: AdaptyPluginEvent {
        let id = "flow_view_did_request_app_review"
        let view: AdaptyUI.FlowView

        enum CodingKeys: String, CodingKey {
            case id
            case view
        }
    }
}
