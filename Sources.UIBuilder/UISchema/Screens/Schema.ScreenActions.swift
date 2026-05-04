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
        onWillAppear: nil,
        onWillDisappear: nil,
        onDidAppear: nil,
        onDidDisappear: nil
    )
}

extension Schema.ScreenActions: Decodable {
    enum CodingKeys: String, CodingKey {
        case onOutsideTap = "on_outside_tap"
        case onDeviceBack = "on_device_back"
        case onFocusChange = "on_focus_change"
        case onWillAppear = "on_will_appear"
        case onWillDisappear = "on_will_disappear"
        case onDidAppear = "on_did_appear"
        case onDidDisappear = "on_did_disappear"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            onOutsideTap: container.decodeIfPresentActions(forKey: .onOutsideTap),
            onDeviceBack: container.decodeIfPresentActions(forKey: .onDeviceBack),
            onFocusChange: container.decodeIfPresentActions(forKey: .onFocusChange),
            onWillAppear: container.decodeIfPresentActions(forKey: .onWillAppear),
            onWillDisappear: container.decodeIfPresentActions(forKey: .onWillDisappear),
            onDidAppear: container.decodeIfPresentActions(forKey: .onDidAppear),
            onDidDisappear: container.decodeIfPresentActions(forKey: .onDidDisappear)
        )
    }

}
