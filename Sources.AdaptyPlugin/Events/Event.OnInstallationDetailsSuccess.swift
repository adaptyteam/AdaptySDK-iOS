//
//  Event.OnInstallationDetailsSuccess.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 25.06.2025.
//

import Adapty
import Foundation

extension Event {
    struct OnInstallationDetailsSuccess: AdaptyPluginEvent {
        let id = "on_installation_details_success"
        let details: AdaptyInstallationDetails

        enum CodingKeys: CodingKey {
            case id
            case details
        }
    }
}
