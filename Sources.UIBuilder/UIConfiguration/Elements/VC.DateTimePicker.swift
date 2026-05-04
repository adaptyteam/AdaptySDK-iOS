//
//  VC.DateTimePicker.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 15.03.2026.
//

import Foundation

extension VC {
    struct DateTimePicker: Sendable {
        let kind: Kind
        let value: Variable
        let components: Components
        let maxDate: VC.DateTime?
        let minDate: VC.DateTime?
        let color: AssetReference?
    }
}

