//
//  Event.OnInstallationDetailsFail.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 25.06.2025.
//

import Adapty
import Foundation

extension Event {
    struct OnInstallationDetailsFail: AdaptyPluginEvent {
        let id = "on_installation_details_fail"
        let error: AdaptyError

        enum CodingKeys: CodingKey {
            case id
            case error
        }
    }
}
