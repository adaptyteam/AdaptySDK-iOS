//
//  Event.DidRequestPermission.swift
//  AdaptyPlugin
//

import Foundation

extension Event {
    struct DidRequestPermission: AdaptyPluginEvent {
        let id = "did_request_permission"
        let requestId: String
        let permission: String
        let customArgs: [String: String]?

        enum CodingKeys: String, CodingKey {
            case id
            case requestId = "request_id"
            case permission
            case customArgs = "custom_args"
        }
    }
}
