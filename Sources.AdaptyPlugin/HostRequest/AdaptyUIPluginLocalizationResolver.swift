//
//  AdaptyUIPluginLocalizationResolver.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 18.11.2026.
//

import AdaptyUIBuilder

struct AdaptyUIPluginLocalizationResolver: AdaptyUICustomLocalizationResolver {
    let id: String

    func resolve(for locales: [String], from source: AdaptyUILocalizationSource) async -> String? {
        // TODO: ask the host
        //
        // native -> host event (`event_id` correlates the answer):
        // {
        //   "id": "<event name>",
        //   "event_id": "hr_1",                  // required, string
        //   "resolver_id": "<id>",               // required, string
        //   "preferred_locales": ["en-US"],      // required, array of string, may be empty
        //   "locales": ["en", "ru"],             // required, array of string, may be empty
        //   "default_locale": "en"               // optional, string
        // }
        //
        // host -> native request (resolves `event_id` via `HostRequestRegistry.shared.resolve`):
        // {
        //   "method": "<answer method>",
        //   "event_id": "hr_1",                  // required, string
        //   "result": "ru"                       // optional, string; null -> the fallback resolver chooses
        // }
        //
        // Unknown `resolver_id`, an error or a flushed request -> nil (the fallback resolver chooses).
        nil
    }
}
