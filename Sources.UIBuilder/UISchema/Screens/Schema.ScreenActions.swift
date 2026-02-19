//
//  Schema.ScreenActions.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 18.02.2026.
//

import Foundation

extension Schema {
    typealias ScreenActions = VC.ScreenActions
}

extension Schema.ScreenActions {
    static let empty = Self(
        onOutsideTap: nil,
        onSystemBack: nil
    )
}

extension Schema.ScreenActions: Codable {
    enum CodingKeys: String, CodingKey {
        case onOutsideTap = "on_outside_tap"
        case onSystemBack = "on_system_back"
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            onOutsideTap: container.decodeIfPresentActions(forKey: .onOutsideTap),
            onSystemBack: container.decodeIfPresentActions(forKey: .onSystemBack)
        )
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(onOutsideTap, forKey: .onOutsideTap)
        try container.encodeIfPresent(onSystemBack, forKey: .onSystemBack)
    }
}
