//
//  VC.TextField.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 14.01.2026.
//

import Foundation

package extension VC {
    struct TextField: Hashable {
        let kind: Kind
        package let value: Variable
        let placeholder: Placeholder?
        let secureEntry: Bool
        package let horizontalAlign: HorizontalAlignment
        let inputConstraints: InputConstraints?
        let validation: Variable?
        package let defaultTextAttributes: Text.Attributes?
        let invalidTextAttributes: Text.Attributes?
        let keyboardOptions: KeyboardOptions?
        let maxRows: Int?
        let minRows: Int?
    }
}
