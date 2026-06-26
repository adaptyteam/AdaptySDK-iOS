//
//  FlowViewEvent.ObserverDidInitiateRestore.swift
//  AdaptyPlugin
//

import Adapty
import AdaptyUI
import Foundation

extension FlowViewEvent {
    struct ObserverDidInitiateRestore: AdaptyPluginEvent {
        let id = "flow_view_observer_did_initiate_restore"
        let view: AdaptyUI.FlowView
        let eventId: String

        enum CodingKeys: String, CodingKey {
            case id
            case view
            case eventId = "event_id"
        }
    }
}
