//
//  Event.DidLoadLatestProfile.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 20.11.2024.
//

import Adapty
import Foundation

extension Event {
    struct DidLoadLatestProfile: AdaptyPluginEvent {
        let id = "did_load_latest_profile"
        let profile: AdaptyProfile

        enum CodingKeys: CodingKey {
            case id
            case profile
        }
    }
}
