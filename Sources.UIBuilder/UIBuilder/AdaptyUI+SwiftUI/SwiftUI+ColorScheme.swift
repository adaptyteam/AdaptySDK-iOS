//
//  SwiftUI+ColorScheme.swift
//  Adapty
//
//  Created by Alex Goncharov on 15/01/2026.
//

import SwiftUI

extension ColorScheme {
    var toVCMode: VC.Mode {
        switch self {
        case .dark: .dark
        default: .light
        }
    }
}
