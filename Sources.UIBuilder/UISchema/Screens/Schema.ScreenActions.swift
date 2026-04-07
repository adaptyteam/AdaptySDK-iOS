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
        onDeviceBack: nil,
        onFocusChange: nil,
        onWillAppiar: nil,
        onWillDisapper: nil,
        onDidAppiar: nil,
        onDidDisapper: nil
    )
}

extension Schema.ScreenActions: Codable {
    enum CodingKeys: String, CodingKey {
        case onOutsideTap = "on_outside_tap"
        case onDeviceBack = "on_device_back"
        case onFocusChange = "on_focus_change"
        case onWillAppiar = "on_will_appiar"
        case onWillDisapper = "on_will_disappiar"
        case onDidAppiar = "on_did_appiar"
        case onDidDisapper = "on_did_disappiar"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            onOutsideTap: container.decodeIfPresentActions(forKey: .onOutsideTap),
            onDeviceBack: container.decodeIfPresentActions(forKey: .onDeviceBack),
            onFocusChange: container.decodeIfPresentActions(forKey: .onFocusChange),
            onWillAppiar: container.decodeIfPresentActions(forKey: .onWillAppiar),
            onWillDisapper: container.decodeIfPresentActions(forKey: .onWillDisapper),
            onDidAppiar: container.decodeIfPresentActions(forKey: .onDidAppiar),
            onDidDisapper: container.decodeIfPresentActions(forKey: .onDidDisapper)
        )
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(onOutsideTap, forKey: .onOutsideTap)
        try container.encodeIfPresent(onDeviceBack, forKey: .onDeviceBack)
        try container.encodeIfPresent(onFocusChange, forKey: .onFocusChange)
        try container.encodeIfPresent(onWillAppiar, forKey: .onWillAppiar)
        try container.encodeIfPresent(onWillDisapper, forKey: .onWillDisapper)
        try container.encodeIfPresent(onDidAppiar, forKey: .onDidAppiar)
        try container.encodeIfPresent(onDidDisapper, forKey: .onDidDisapper)
    }
}

