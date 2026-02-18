//
//  VC.Screen.LayoutBehaviour.swift
//  Adapty
//
//  Created by Aleksei Valiano on 18.02.2026.
//

import Foundation

package extension VC.Screen {
    enum LayoutBehaviour: Sendable, Hashable {
        case `default`
        case flat
        case transparent
        case hero
    }
}
