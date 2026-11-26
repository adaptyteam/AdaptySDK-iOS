//
//  AdaptyUIPluginLocalizationResolver.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 18.11.2026.
//

import AdaptyUIBuilder
import Foundation

/// Asks the host's custom localization resolver `id` to choose a flow localization
/// (`flow_view_did_ask_localization` -> `flow_view_did_answer_localization`).
///
/// `nil` lets the fallback resolver choose. That happens when no event handler is
/// registered, when the host answers `null` (e.g. for an unknown `resolver_id`),
/// when the request is flushed on teardown, and when the host does not answer
/// within `timeout`. A non-null answer is handled like that of any custom resolver:
/// an id the schema does not have is ignored, and the fallback resolver chooses.
struct AdaptyUIPluginLocalizationResolver: AdaptyUICustomLocalizationResolver {
    /// The answer is a pure choice from the lists in the event, so a responsive
    /// host replies within one channel round-trip (milliseconds). The limit only
    /// caps how long a host that never answers (no handler, an older host
    /// library, a hung callback) can delay flow view creation.
    static let defaultTimeout: TimeInterval = 2

    let id: String
    let timeout: TimeInterval
    /// Overrides `AdaptyPlugin.sharedEventHandler`; for tests.
    let eventHandler: (any EventHandler)?

    init(id: String, timeout: TimeInterval = Self.defaultTimeout, eventHandler: (any EventHandler)? = nil) {
        self.id = id
        self.timeout = timeout
        self.eventHandler = eventHandler
    }

    @MainActor
    func resolve(for locales: [String], from source: AdaptyUILocalizationSource) async -> String? {
        guard let eventHandler = eventHandler ?? AdaptyPlugin.sharedEventHandler else { return nil }

        return await HostRequestRegistry.shared.perform(String.self, timeout: timeout) { eventId in
            eventHandler.handle(event: FlowViewEvent.DidAskLocalization(
                eventId: eventId,
                resolverId: id,
                preferredLocales: locales,
                locales: source.locales,
                defaultLocale: source.defaultLocale
            ))
        }
    }
}
