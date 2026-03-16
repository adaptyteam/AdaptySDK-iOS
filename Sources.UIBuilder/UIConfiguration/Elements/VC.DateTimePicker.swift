//
//  VC.DateTimePicker.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 15.03.2026.
//

import Foundation

extension VC {
    struct DateTimePicker: Hashable {
        let kind: Kind
        let value: Variable
        let components: Components
        let maxDate: Date?
        let minDate: Date?
        let color: AssetReference?
        
    }
}
