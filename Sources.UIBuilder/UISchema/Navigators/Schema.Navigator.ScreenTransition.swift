//
//  Schema.Navigator.ScreenTransition.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 11.02.2026.
//

import Foundation

extension Schema.Navigator {
    typealias ScreenTransition = VC.Navigator.ScreenTransition
}

extension Schema.Navigator.ScreenTransition: Codable {
    enum CodingKeys: String, CodingKey {
        case outgoing
        case incoming
        case isIncomingOnTop = "is_incoming_on_top"
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        try self.init(
            outgoing: container.decodeIfPresent([Schema.Animation].self, forKey: .outgoing),
            incoming: container.decodeIfPresent([Schema.Animation].self, forKey: .incoming),
            isIncomingOnTop: container.decode(Bool.self, forKey: .isIncomingOnTop)
        )
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let outgoing, outgoing.isNotEmpty { try container.encode(outgoing, forKey: .outgoing) }
        if let incoming, incoming.isNotEmpty { try container.encode(incoming, forKey: .incoming) }
        try container.encode(isIncomingOnTop, forKey: .isIncomingOnTop)
    }
}
