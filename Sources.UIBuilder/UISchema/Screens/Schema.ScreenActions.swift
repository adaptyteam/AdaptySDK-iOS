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
        onDeviceBack: nil
    )
}

extension Schema.ScreenActions: Codable {
    enum CodingKeys: String, CodingKey {
        case onOutsideTap = "on_outside_tap"
        case onDeviceBack = "on_device_back"
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            onOutsideTap: container.decodeIfPresentActions(forKey: .onOutsideTap),
            onDeviceBack: container.decodeIfPresentActions(forKey: .onDeviceBack)
        )
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(onOutsideTap, forKey: .onOutsideTap)
        try container.encodeIfPresent(onDeviceBack, forKey: .onDeviceBack)
    }
}
