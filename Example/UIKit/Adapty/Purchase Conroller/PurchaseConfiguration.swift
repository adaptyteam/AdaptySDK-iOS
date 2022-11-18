//
//  PurchaseConfiguration.swift
//  Adapty_Example
//
//  Created by Aleksey Goncharov on 17.08.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

import Adapty
import UIKit

struct PurchaseConfiguration {
    let title: String
    let subtitle: String
    let accentColor: UIColor
    let backgroundColor: UIColor
}

// Custom Payload Format:
//    {
//      "title": "Meet Premium Subscription:",
//      "subtitle": "* benefit 1\n* benefit 2\n* benefit 3",
//      "accent_color": "#781C68",
//      "background_color": "#FFF5E1"
//    }

extension PurchaseConfiguration {
    static let `default` = PurchaseConfiguration(title: "Title", subtitle: "Subtitle", accentColor: .systemBlue, backgroundColor: .systemBackground)
}

extension AdaptyPaywall {
    func isHorizontal() -> Bool {
        remoteConfig?["is_horizontal"] as? Bool ?? false
    }
    
    func extractPurchaseConfiguration() -> PurchaseConfiguration {
        guard let config = remoteConfig else { return PurchaseConfiguration.default }

        let title = (config["title"] as? String) ?? PurchaseConfiguration.default.title
        let subtitle = (config["subtitle"] as? String) ?? PurchaseConfiguration.default.subtitle

        let accentColor: UIColor
        if let accentColorString = config["accent_color"] as? String {
            accentColor = UIColor.fromHex(hexString: accentColorString)
        } else {
            accentColor = PurchaseConfiguration.default.accentColor
        }

        let backgroundColor: UIColor
        if let backgroundColorString = config["background_color"] as? String {
            backgroundColor = UIColor.fromHex(hexString: backgroundColorString)
        } else {
            backgroundColor = PurchaseConfiguration.default.backgroundColor
        }

        return PurchaseConfiguration(title: title, subtitle: subtitle, accentColor: accentColor, backgroundColor: backgroundColor)
    }
}
