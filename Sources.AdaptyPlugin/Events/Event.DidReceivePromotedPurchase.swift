//
//  Event.DidReceivePromotedPurchase.swift
//  AdaptyPlugin
//
//  Created by Codex on 03.07.2026.
//

import Foundation

extension Event {
    struct DidReceivePromotedPurchase: AdaptyPluginEvent {
        let id = "did_receive_promoted_purchase"
        let product: Response.AdaptyPluginPromotedProduct

        enum CodingKeys: CodingKey {
            case id
            case product
        }
    }
}
