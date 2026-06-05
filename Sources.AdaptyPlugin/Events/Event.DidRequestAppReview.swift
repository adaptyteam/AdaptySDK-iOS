//
//  Event.DidRequestAppReview.swift
//  AdaptyPlugin
//

import Foundation

extension Event {
    struct DidRequestAppReview: AdaptyPluginEvent {
        let id = "did_request_app_review"

        enum CodingKeys: String, CodingKey {
            case id
        }
    }
}
