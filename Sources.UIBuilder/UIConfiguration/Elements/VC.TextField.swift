//
//  VC.TextField.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 14.01.2026.
//

import Foundation

extension VC {
    struct TextField: Sendable {
        let kind: Kind
        let value: Variable
        let placeholder: Placeholder?
        let secureEntry: Bool
        let horizontalAlign: HorizontalAlignment
        let inputConstraints: InputConstraints?
        let validation: Variable?
        let defaultTextAttributes: TextAttributes?
        let invalidTextAttributes: TextAttributes?
        let keyboardOptions: KeyboardOptions?
        let keyboardSubmitActions: [Action]
        let maxRows: Int?
        let minRows: Int?
    }
}
