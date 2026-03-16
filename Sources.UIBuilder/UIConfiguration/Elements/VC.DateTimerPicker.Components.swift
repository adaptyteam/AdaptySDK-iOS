//
//  VC.DateTimerPicker.Components.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 15.03.2026.
//

import Foundation

extension VC.DateTimePicker {
    struct Components: OptionSet, Hashable {
        let rawValue: Int

        static let date = Self(rawValue: 1 << 0)
        static let hourAndMinute = Self(rawValue: 1 << 1)
    }
}
