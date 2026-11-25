//
//  FlowViewEvent.DidAskLocalization.swift
//  AdaptyPlugin
//

import Foundation

extension FlowViewEvent {
    /// Asks the host's custom localization resolver to choose a flow localization.
    /// Sent while the flow view is being created, so it carries no `view`.
    struct DidAskLocalization: AdaptyPluginEvent {
        let id = "flow_view_did_ask_localization"
        let eventId: String
        let resolverId: String
        let preferredLocales: [String]
        let locales: [String]
        let defaultLocale: String?

        enum CodingKeys: String, CodingKey {
            case id
            case eventId = "event_id"
            case resolverId = "resolver_id"
            case preferredLocales = "preferred_locales"
            case locales
            case defaultLocale = "default_locale"
        }
    }
}
