//
//  Schema.Pager.InteractionBehavior.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.11.2025.
//

import Foundation

extension Schema.Pager {
    typealias InteractionBehavior = VC.Pager.InteractionBehavior
}

extension Schema.Pager.InteractionBehavior {
    static let `default` = Self.pauseAnimation
}

extension Schema.Pager.InteractionBehavior: RawRepresentable {
    private enum Key {
        static let none = "none"
        static let cancelAnimation = "cancel_animation"
        static let pauseAnimation = "pause_animation"
    }

    package init?(rawValue value: String) {
        switch value {
        case Key.none: self = .none
        case Key.cancelAnimation: self = .cancelAnimation
        case Key.pauseAnimation: self = .pauseAnimation
        default: return nil
        }
    }

    package var rawValue: String {
        switch self {
        case .none: Key.none
        case .cancelAnimation: Key.cancelAnimation
        case .pauseAnimation: Key.pauseAnimation
        }
    }
}

extension Schema.Pager.InteractionBehavior: Codable {}
